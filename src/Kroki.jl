"""
The main `Module` containing the necessary types of functions for integration
with a Kroki service.

Defines `Base.show` and corresponding `Base.showable` methods for different
output formats and [`Diagram`](@ref Kroki.Diagram) types, so they render in
their most optimal form in different environments (e.g. the documentation
system, Documenter output, Pluto, Jupyter, etc.).
"""
module Kroki

using Base64: base64encode
using CodecZlib: ZlibCompressor, transcode
using HTTP: request
using Reexport: @reexport

include("./kroki/documentation.jl")
using .Documentation
@setupDocstringMarkup()

export Diagram, render

# Convenience short-hand to make further type definitions more straightforward
# to write
const Maybe{T} = Union{Nothing, T} where {T}

"""
A representation of a diagram that can be rendered by a Kroki service.

# Examples

```
julia> Kroki.Diagram(:PlantUML, "Kroki -> Julia: Hello Julia!")
     ┌─────┐          ┌─────┐
     │Kroki│          │Julia│
     └──┬──┘          └──┬──┘
        │ Hello Julia!   │
        │───────────────>│
     ┌──┴──┐          ┌──┴──┐
     │Kroki│          │Julia│
     └─────┘          └─────┘
```
"""
Base.@kwdef struct Diagram
  """
  Options to modify the appearance of the `specification` when rendered.

  Valid options depend on the `type` of diagram. See [Kroki's
  website](https://docs.kroki.io/kroki/setup/diagram-options) for details.

  The keys are case-insensitive. All specified options are passed through to
  Kroki, which ignores unkown options.
  """
  options::Dict{String, String} = Dict{String, String}()

  "The textual specification of the diagram."
  specification::AbstractString

  """
  The type of diagram specification (e.g. ditaa, Mermaid, PlantUML, etc.). This
  value is case-insensitive.
  """
  type::Symbol
end

"""
Constructs a [`Diagram`](@ref) from the `specification` for a specific `type`
of diagram.

Passes keyword arguments through to [`Diagram`](@ref) untouched.
"""
function Diagram(type::Symbol, specification::AbstractString; kwargs...)
  Diagram(; specification, type, kwargs...)
end

include("./kroki/exceptions.jl")
using .Exceptions: DiagramPathOrSpecificationError, RenderError, UnsupportedMIMETypeError

"""
Constructs a [`Diagram`](@ref) from the `specification` for a specific `type`
of diagram, or loads the `specification` from the provided `path`.

Specifying both keyword arguments, or neither, is invalid.

Passes any further keyword arguments through to [`Diagram`](@ref) untouched.
"""
function Diagram(
  type::Symbol;
  path::Maybe{AbstractString} = nothing,
  specification::Maybe{AbstractString} = nothing,
  kwargs...,
)
  path_provided = !isnothing(path)
  specification_provided = !isnothing(specification)

  if path_provided && specification_provided
    throw(DiagramPathOrSpecificationError(path, specification))
  elseif !path_provided && !specification_provided
    throw(DiagramPathOrSpecificationError(path, specification))
  end

  Diagram(;
    specification = path_provided ? read(path, String) : specification,
    type,
    kwargs...,
  )
end

"""
Compresses a [`Diagram`](@ref)'s `specification` using
[zlib](https://zlib.net), turning the resulting bytes into a URL-safe Base64
encoded payload (i.e. replacing `+` by `-` and `/` by `_`) to be used in
communication with a Kroki service.

See the [Kroki documentation](https://docs.kroki.io/kroki/setup/encode-diagram)
for more information.
"""
UriSafeBase64Payload(diagram::Diagram) = foldl(
  replace,
  ['+' => '-', '/' => '_'];
  init = base64encode(transcode(ZlibCompressor, diagram.specification)),
)

"""
Renders a [`Diagram`](@ref) through a Kroki service to the specified output
format.

Allows the specification of [diagram
options](https://docs.kroki.io/kroki/setup/diagram-options) through the
`options` keyword. The `options` default to those specified on the
[`Diagram`](@ref).

If the Kroki service responds with an error, throws an
[`InvalidDiagramSpecificationError`](@ref
Kroki.Exceptions.InvalidDiagramSpecificationError) or
[`InvalidOutputFormatError`](@ref Kroki.Exceptions.InvalidOutputFormatError) if
a known type of error occurs. Other errors (e.g.
`HTTP.ExceptionRequest.StatusError` for connection errors) are propagated if
they occur.

_SVG output is supported for all [`Diagram`](@ref) types_. See the [support
table](@ref diagram-support) for an overview of other supported output formats
per diagram type and [`overrideShowable`](@ref) in case it is necessary to
override default `Base.show` behavior, e.g. to disable a specific output
format.
"""
render(
  diagram::Diagram,
  output_format::AbstractString;
  options::Dict{String, String} = diagram.options,
) =
  try
    getfield(
      request(
        "GET",
        join(
          [
            ENDPOINT[],
            lowercase("$(diagram.type)"),
            output_format,
            UriSafeBase64Payload(diagram),
          ],
          '/',
        ),
        # Pass all diagram options as headers to Kroki by prepending the
        # necessary prefix to all provided `options`. This ensures this package
        # does not have to be updated whenever new options are added to the
        # service
        "Kroki-Diagram-Options-" .* keys(options) .=> values(options),
      ),
      :body,
    )
  catch exception
    throw(RenderError(diagram, exception))
  end

# Helper constant to type a map from MIME to `Diagram` types  more easily
const MIMEToDiagramTypeMap = Dict{MIME, Tuple{Symbol, Vararg{Symbol}}}

# Helper function to render a support matrix for inclusion in Markdown
# documentation, e.g. `LIMITED_DIAGRAM_SUPPORT`'s docstring
function renderDiagramSupportAsMarkdown(support::MIMEToDiagramTypeMap)
  # SVG support should always be included for all diagram types, even if it is
  # not in the support map
  mime_types = MIME.(sort(unique([string.(keys(support))..., "image/svg+xml"])))

  header = """
  | | `$(join(mime_types, "` | `"))` |
  | --: $(repeat("| :-: ", length(mime_types)))|
  """

  diagram_types = sort(unique(Iterators.flatten(values(support))))
  diagram_types_with_support = map(diagram_types) do diagram_type
    return [
      toMarkdownLink(diagram_type),
      map(
        mime -> mime === MIME"image/svg+xml"() || diagram_type ∈ support[mime] ? "✅" : "",
        mime_types,
      )...,
    ]
  end

  diagram_support_markdown_rows =
    string.("| ", join.(diagram_types_with_support, " | "), " |")

  return header * join(diagram_support_markdown_rows, '\n')
end

"""
A container to associate metadata with a specific diagram type, e.g. for
documentation purposes.
"""
struct DiagramTypeMetadata
  "A more readable name for the diagram type, if applicable."
  name::String

  "The URL to the website/documentation of the diagram type."
  url::String
end

# This is a common transformation across different documentation sections,
# hence convenient to be available as helper functions
toMarkdownLink(dtm::DiagramTypeMetadata) = "[$(dtm.name)]($(dtm.url))"
toMarkdownLink(diagram_type::Symbol) = toMarkdownLink(getDiagramTypeMetadata(diagram_type))

"""
An overview of metadata for the different [`Diagram`](@ref) `type`s that can be
rendered, e.g. links to the main documentation, friendly names, etc.
"""
DIAGRAM_TYPE_METADATA = Dict{Symbol, DiagramTypeMetadata}(
  :actdiag => DiagramTypeMetadata("actdiag", "http://blockdiag.com/en/actdiag"),
  :blockdiag => DiagramTypeMetadata("blockdiag", "http://blockdiag.com/en/blockdiag"),
  :bpmn => DiagramTypeMetadata("BPMN", "https://www.omg.org/spec/BPMN"),
  :bytefield =>
    DiagramTypeMetadata("Byte Field", "https://bytefield-svg.deepsymmetry.org"),
  :c4plantuml => DiagramTypeMetadata(
    "C4 with PlantUML",
    "https://github.com/plantuml-stdlib/C4-PlantUML",
  ),
  :d2 => DiagramTypeMetadata("D2", "https://d2lang.com"),
  :dbml => DiagramTypeMetadata("DBML", "https://dbml.org"),
  :diagramsnet => DiagramTypeMetadata("diagrams.net", "https://diagrams.net"),
  :ditaa => DiagramTypeMetadata("ditaa", "http://ditaa.sourceforge.net"),
  :erd => DiagramTypeMetadata("erd", "https://github.com/BurntSushi/erd"),
  :excalidraw => DiagramTypeMetadata("Excalidraw", "https://excalidraw.com"),
  :graphviz => DiagramTypeMetadata("Graphviz", "https://graphviz.org"),
  :mermaid => DiagramTypeMetadata("Mermaid", "https://mermaid-js.github.io"),
  :nomnoml => DiagramTypeMetadata("nomnoml", "https://www.nomnoml.com"),
  :nwdiag => DiagramTypeMetadata("nwdiag", "http://blockdiag.com/en/nwdiag"),
  :packetdiag => DiagramTypeMetadata("packetdiag", "http://blockdiag.com/en/nwdiag"),
  :pikchr => DiagramTypeMetadata("Pikchr", "https://pikchr.org"),
  :plantuml => DiagramTypeMetadata("PlantUML", "https://plantuml.com"),
  :rackdiag => DiagramTypeMetadata("rackdiag", "http://blockdiag.com/en/nwdiag"),
  :seqdiag => DiagramTypeMetadata("seqdiag", "http://blockdiag.com/en/seqdiag"),
  :structurizr => DiagramTypeMetadata("Structurizr", "https://structurizr.com"),
  :svgbob =>
    DiagramTypeMetadata("Svgbob", "https://ivanceras.github.io/content/Svgbob.html"),
  :symbolator =>
    DiagramTypeMetadata("Symbolator", "https://github.com/kevinpt/symbolator"),
  :tikz => DiagramTypeMetadata("TikZ/PGF", "https://github.com/pgf-tikz/pgf"),
  :umlet => DiagramTypeMetadata("UMLet", "https://github.com/umlet/umlet"),
  :vega => DiagramTypeMetadata("Vega", "https://vega.github.io/vega"),
  :vegalite => DiagramTypeMetadata("Vega-Lite", "https://vega.github.io/vega-lite"),
  :wavedrom => DiagramTypeMetadata("WaveDrom", "https://wavedrom.com"),
  :wireviz => DiagramTypeMetadata("WireViz", "https://github.com/formatc1702/WireViz"),
)

"""
Retrieves the metadata for a given `diagram_type` from
[`DIAGRAM_TYPE_METADATA`](@ref), with a fallback to a generic
[`DiagramTypeMetadata`](@ref).
"""
getDiagramTypeMetadata(diagram_type::Symbol)::DiagramTypeMetadata = get(
  DIAGRAM_TYPE_METADATA,
  diagram_type,
  DiagramTypeMetadata(
    "$(diagram_type)",
    "https://bauglir.github.io/Kroki.jl/stable/#diagram-support",
  ),
)

"""
Some MIME types are not supported by all diagram types, this constant contains
all these limitations. The union of all values corresponds to all supported
[`Diagram`](@ref) `type`s.

Note that SVG output is supported by all diagram types, as is reflected in the
support matrix below. Only those diagram types that explicitly _only_ support
SVG output are included in this constant.

Those diagram types that support plain text output, i.e. not just rendering
their `specification`, support both ASCII and Unicode character sets for
rendering. This is expressed using two different `text/plain` MIME types. See
also [`SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES`](@ref).

# Support Matrix

$(renderDiagramSupportAsMarkdown(LIMITED_DIAGRAM_SUPPORT))
"""
const LIMITED_DIAGRAM_SUPPORT = MIMEToDiagramTypeMap(
  MIME"application/pdf"() => (
    :actdiag,
    :blockdiag,
    :c4plantuml,
    :erd,
    :graphviz,
    :nwdiag,
    :packetdiag,
    :plantuml,
    :rackdiag,
    :seqdiag,
    :structurizr,
    :tikz,
    :vega,
    :vegalite,
  ),
  MIME"image/jpeg"() => (:erd, :graphviz, :tikz, :umlet),
  MIME"image/png"() => (
    :actdiag,
    :blockdiag,
    :c4plantuml,
    :diagramsnet,
    :ditaa,
    :erd,
    :graphviz,
    :mermaid,
    :nwdiag,
    :packetdiag,
    :plantuml,
    :rackdiag,
    :seqdiag,
    :structurizr,
    :symbolator,
    :tikz,
    :umlet,
    :vega,
    :vegalite,
    :wireviz,
  ),
  MIME"image/svg+xml"() =>
    (:bpmn, :bytefield, :d2, :dbml, :excalidraw, :nomnoml, :pikchr, :svgbob, :wavedrom),
  MIME"text/plain"() => (:c4plantuml, :plantuml, :structurizr),
  MIME"text/plain; charset=utf-8"() => (:c4plantuml, :plantuml, :structurizr),
)

"""
Maps MIME types to the arguments that have to be passed to the [`render`](@ref)
function, which are in turned passed to the Kroki service.
"""
const MIME_TO_RENDER_ARGUMENT_MAP = Dict{MIME, String}(
  MIME"application/pdf"() => "pdf",
  MIME"image/jpeg"() => "jpeg",
  MIME"image/png"() => "png",
  MIME"image/svg+xml"() => "svg",
  MIME"text/plain"() => "txt",
  MIME"text/plain; charset=utf-8"() => "utxt",
)

"""
Normalizes the `type` of the [`Diagram`](@ref) enabling consistent comparisons,
etc. while enabling user-facing case insensitivity.
"""
normalizeDiagramType(diagram::Diagram) = normalizeDiagramType(diagram.type)
normalizeDiagramType(diagram_type::Symbol) = Symbol(lowercase(String(diagram_type)))

"""
Overrides the behavior of `Base.showable` for a specific `output_format` and
`diagram_type` relative to what is recorded in
[`LIMITED_DIAGRAM_SUPPORT`](@ref). The overrides are tracked through
[`SHOWABLE_OVERRIDES`](@ref).

Note that overriding whether a diagram type is `showable` for a specific output
format, specifically enabling one, requires the Kroki service to support it for
a diagram to properly render!
"""
function overrideShowable(output_format::MIME, diagram_type::Symbol, supported::Bool)
  SHOWABLE_OVERRIDES[(normalizeDiagramType(diagram_type), output_format)] = supported
end

"""
Resets [`SHOWABLE_OVERRIDES`](@ref) so that the default `showable` support is
enabled for all diagram types.
"""
resetShowableOverrides() = empty!(SHOWABLE_OVERRIDES)

"""
Tracks overrides that should be applied to the output format support registered
in [`LIMITED_DIAGRAM_SUPPORT`](@ref) for specific diagram types.

Typically used to disable an output format that might selected by `Base.show`
to render a specific diagram type to for a given display in case that produces
undesired results. Can also be used to enable output formats in addition to SVG
for new diagram types that support them and that may not have been added to
this package's [`LIMITED_DIAGRAM_SUPPORT`](@ref) yet.

Should be manipulated using [`overrideShowable`](@ref) and
[`resetShowableOverrides`](@ref).
"""
const SHOWABLE_OVERRIDES = Dict{Tuple{Symbol, MIME}, Bool}()

# `Base.show` methods should only be defined for diagram types that actually
# support the desired output format. This would make sure incompatible formats
# are not accidentally rendered on compatible `AbstractDisplay`s causing
# [`InvalidOutputFormatError`](@ref)s. As the diagram type information is only
# available within [`Diagram`](@ref) instances, the `show` method is defined
# generically, but then restricted using `Base.showable` to only those types
# that actually support the format
Base.show(io::IO, ::T, diagram::Diagram) where {T <: MIME} =
  write(io, render(diagram, MIME_TO_RENDER_ARGUMENT_MAP[T()]))

# The `text/plain` MIME type needs to be explicitly defined to remove method
# ambiguities. As the two argument `Base.show` method is the one that is meant
# to render this MIME type, it is simply forwarded to that method
Base.show(io::IO, ::MIME"text/plain", diagram::Diagram) = show(io, diagram)

function Base.showable(output_format::T, diagram::Diagram) where {T <: MIME}
  diagram_type = normalizeDiagramType(diagram)

  override_index = (diagram_type, output_format)
  if haskey(SHOWABLE_OVERRIDES, override_index)
    return SHOWABLE_OVERRIDES[override_index]
  elseif T === MIME"image/svg+xml"
    # SVG output is supported by _all_ diagram types. Instead of encoding
    # this for all types  in `LIMITED_DIAGRAM_SUPPORT` this is tracked here
    # so that SVG output also works for new diagram types if they get added
    # to the Kroki service, but not yet to this package
    return true
  else
    return diagram_type ∈ get(LIMITED_DIAGRAM_SUPPORT, output_format, Tuple([]))
  end
end

"""
Defines the MIME type to be used when `show` gets called on a [`Diagram`](@ref)
for the `text/plain` MIME type.

Should be set to a variation of the `text/plain` MIME type. For instance,
`text/plain; charset=utf-8` to enable Unicode rendering for certain diagrams,
e.g. PlantUML and Structurizr.

Only a select number of variations are supported, see
[`LIMITED_DIAGRAM_SUPPORT`](@ref) and
[`SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES`](@ref) for details.

Defaults to `$(TEXT_PLAIN_SHOW_MIME_TYPE[])`.
"""
const TEXT_PLAIN_SHOW_MIME_TYPE = Ref{MIME}(MIME"text/plain; charset=utf-8"())

"""
The values that can be used to configure [`TEXT_PLAIN_SHOW_MIME_TYPE`](@ref):
$(join(string.("  * `", SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES), "`\n"))`
"""
const SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES = Set([
  mime for
  mime in keys(Kroki.LIMITED_DIAGRAM_SUPPORT) if startswith(string(mime), "text/plain")
])

# The two-argument `Base.show` version is used to render the "text/plain" MIME
# type. Those `Diagram` types that support text-based rendering, e.g. PlantUML,
# Structurizr, should render those. All others should render their
# `specification`.
#
# Whether `text/plain` rendering uses ASCII or Unicode characters is controlled
# using the `Kroki.TEXT_PLAIN_SHOW_MIME_TYPE` variable
function Base.show(io::IO, diagram::Diagram)
  text_plain_show_mimetype = TEXT_PLAIN_SHOW_MIME_TYPE[]

  if text_plain_show_mimetype ∉ SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES
    throw(
      UnsupportedMIMETypeError(
        text_plain_show_mimetype,
        SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES,
      ),
    )
  end

  if showable(text_plain_show_mimetype, diagram)
    write(io, render(diagram, MIME_TO_RENDER_ARGUMENT_MAP[text_plain_show_mimetype]))
  else
    write(io, diagram.specification)
  end
end

include("./kroki/service.jl")
using .Service: ENDPOINT

include("./kroki/string_literals.jl")
@reexport using .StringLiterals

end
