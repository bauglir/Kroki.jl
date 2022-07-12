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
using HTTP.ExceptionRequest: StatusError

include("./kroki/documentation.jl")
using .Documentation
@setupDocstringMarkup()

include("./kroki/service.jl")
using .Service: ENDPOINT

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
struct Diagram
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
"""
Diagram(type::Symbol, specification::AbstractString) = Diagram(specification, type)

"""
Constructs a [`Diagram`](@ref) from the `specification` for a specific `type`
of diagram, or loads the `specification` from the provided `path`.

Specifying both keyword arguments, or neither, is invalid.
"""
function Diagram(
  type::Symbol;
  path::Maybe{AbstractString} = nothing,
  specification::Maybe{AbstractString} = nothing,
)
  path_provided = !isnothing(path)
  specification_provided = !isnothing(specification)

  if path_provided && specification_provided
    throw(DiagramPathOrSpecificationError(path, specification))
  elseif !path_provided && !specification_provided
    throw(DiagramPathOrSpecificationError(path, specification))
  elseif path_provided
    Diagram(type, read(path, String))
  else
    Diagram(type, specification)
  end
end

"""
An `Exception` to be thrown when the `path` and `specification` keyword
arguments to [`Diagram`](@ref) are not specified mutually exclusive.
"""
struct DiagramPathOrSpecificationError <: Exception
  path::Maybe{AbstractString}
  specification::Maybe{AbstractString}
end

function Base.showerror(io::IO, error::DiagramPathOrSpecificationError)
  not_specified = "<not specified>"

  path_description = isnothing(error.path) ? not_specified : error.path
  specification_description =
    isnothing(error.specification) ? not_specified : error.specification

  message = """
            Either `path` or `specification` should be specified:
              * `path`: '$(path_description)'
              * `specification`: '$(specification_description)'
            """

  print(io, message)
end

"""
An `Exception` to be thrown when a [`Diagram`](@ref) representing an invalid
specification is passed to [`render`](@ref).
"""
struct InvalidDiagramSpecificationError <: Exception
  error::String
  cause::Diagram
end

Base.showerror(io::IO, error::InvalidDiagramSpecificationError) = print(
  io,
  """
  $(RenderErrorHeader(error))

  This is (likely) caused by an invalid diagram specification.
  """,
)

"""
An `Exception` to be thrown when a [`Diagram`](@ref) is [`render`](@ref)ed to
an unsupported or invalid output format.
"""
struct InvalidOutputFormatError <: Exception
  error::String
  cause::Diagram
end

Base.showerror(io::IO, error::InvalidOutputFormatError) = print(
  io,
  """
  $(RenderErrorHeader(error))

  This is (likely) caused by an invalid or unknown output format.
  """,
)

# Helper function to render common headers when showing render errors
function RenderErrorHeader(
  error::Union{InvalidDiagramSpecificationError, InvalidOutputFormatError},
)
  """
  The Kroki service responded with:
  $(error.error)

  In response to a '$(error.cause.type)' diagram with the specification:
  $(error.cause.specification)
  """
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

# Rewrites generic `HTTP.ExceptionRequest.StatusError`s into more specific
# errors based on Kroki's response if possible
function RenderError(diagram::Diagram, exception::StatusError)
  # Both errors related to invalid diagram specifications and invalid or
  # unsupported output formats are denoted by 400 responses, so further
  # processing of the response is necessary
  service_response = String(exception.response.body)

  if occursin("Unsupported output format", service_response)
    InvalidOutputFormatError(service_response, diagram)
  elseif occursin("Syntax Error", service_response)
    InvalidDiagramSpecificationError(service_response, diagram)
  else
    exception
  end
end
RenderError(::Diagram, exception::Exception) = exception

"""
Renders a [`Diagram`](@ref) through a Kroki service to the specified output
format.

If the Kroki service responds with an error, throws an
[`InvalidDiagramSpecificationError`](@ref) or
[`InvalidOutputFormatError`](@ref) if a know type of error occurs. Other errors
(e.g. `HTTP.ExceptionRequest.StatusError` for connection errors) are propagated
if they occur.

_SVG output is supported for all [`Diagram`](@ref) types_. See [Kroki's
website](https://kroki.io/#support) for an overview of other supported output
formats per diagram type. Note that this list may not be entirely up-to-date.
"""
render(diagram::Diagram, output_format::AbstractString) =
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
      ),
      :body,
    )
  catch exception
    throw(RenderError(diagram, exception))
  end

"""
Some MIME types are not supported by all diagram types, this constant contains
all these limitations. The union of all values corresponds to all supported
[`Diagram`](@ref) `type`s.
"""
const LIMITED_DIAGRAM_SUPPORT = Dict{AbstractString, Tuple{Symbol, Vararg{Symbol}}}(
  "application/pdf" => (
    :blockdiag,
    :seqdiag,
    :actdiag,
    :nwdiag,
    :packetdiag,
    :rackdiag,
    :erd,
    :graphviz,
    :vega,
    :vegalite,
  ),
  "image/jpeg" => (:c4plantuml, :erd, :graphviz, :plantuml, :umlet),
  "image/png" => (
    :blockdiag,
    :seqdiag,
    :actdiag,
    :nwdiag,
    :packetdiag,
    :rackdiag,
    :c4plantuml,
    :ditaa,
    :erd,
    :graphviz,
    :mermaid,
    :plantuml,
    :structurizr,
    :umlet,
    :vega,
    :vegalite,
  ),
  # Although all diagram types support SVG, these _only_ support SVG so are
  # included separately
  "image/svg+xml" =>
    (:bpmn, :bytefield, :excalidraw, :nomnoml, :pikchr, :svgbob, :wavedrom),
  "text/plain" => (:c4plantuml, :plantuml),
)

# `Base.show` methods should only be defined for diagram types that actually
# support the desired output format. This would make sure incompatible formats
# are not accidentally rendered on compatible `AbstractDisplay`s causing
# [`InvalidOutputFormatError`](@ref)s. As the diagram type information is only
# available within [`Diagram`](@ref) instances, the `show` method is defined
# generically, but then restricted using `Base.showable` to only those types
# that actually support the format
Base.show(io::IO, ::MIME{Symbol("image/png")}, diagram::Diagram) =
  write(io, render(diagram, "png"))
Base.showable(::MIME{Symbol("image/png")}, diagram::Diagram) =
  diagram.type ∈ LIMITED_DIAGRAM_SUPPORT["image/png"]

# SVG output is supported by _all_ diagram types, so there's no additional
# checking for support. This makes sure SVG output also works for new diagram
# types if they get added to Kroki, but not yet to this package
Base.show(io::IO, ::MIME"image/svg+xml", diagram::Diagram) =
  write(io, render(diagram, "svg"))

# PlantUML is capable of rendering textual representations, all other diagram
# types are not
Base.show(io::IO, diagram::Diagram) =
  if endswith(lowercase("$(diagram.type)"), "plantuml")
    write(io, render(diagram, "utxt"))
  else
    write(io, diagram.specification)
  end

# Helper function implementing string interpolation to be used in conjunction
# with macros defining diagram specification string literals, as they do not
# support string interpolation by default.
#
# Returns an array of elements, e.g. `Expr`essions, `Symbol`s, `String`s that
# can be incorporated in the `args` of another `Expr`essions
function interpolate(specification::AbstractString)
  # Based on the interpolation code from the Markdown stdlib and
  # https://riptutorial.com/julia-lang/example/22952/implementing-interpolation-in-a-string-macro
  components = Any[]

  # Turn the string is into an `IOBuffer` to make it more straightforward to
  # parse it in an incremental fashion
  stream = IOBuffer(specification)

  while !eof(stream)
    # The `$` is omitted from the result by `readuntil` by default, no need for
    # further processing
    push!(components, readuntil(stream, '$'))

    if !eof(stream)
      # If an interpolation indicator was found, try to parse the smallest
      # expression to interpolate and then keep parsing the stream for further
      # interpolations
      started_at = position(stream)
      expr, parsed_count = Meta.parse(read(stream, String), 1; greedy = false)
      seek(stream, started_at + parsed_count - 1)
      push!(components, expr)
    end
  end

  esc.(components)
end

# Links to the main documentation for each diagram type for inclusion in the
# string literal docstrings
DIAGRAM_DOCUMENTATION_URLS = Dict{String, String}(
  "actdiag" => "http://blockdiag.com/en/actdiag",
  "blockdiag" => "http://blockdiag.com/en/blockdiag",
  "bpmn" => "https://www.omg.org/spec/BPMN",
  "bytefield" => "https://bytefield-svg.deepsymmetry.org",
  "c4plantuml" => "https://github.com/plantuml-stdlib/C4-PlantUML",
  "ditaa" => "http://ditaa.sourceforge.net",
  "erd" => "https://github.com/BurntSushi/erd",
  "excalidraw" => "https://excalidraw.com",
  "graphviz" => "https://graphviz.org",
  "mermaid" => "https://mermaid-js.github.io",
  "nomnoml" => "https://www.nomnoml.com",
  "nwdiag" => "http://blockdiag.com/en/nwdiag",
  "packetdiag" => "http://blockdiag.com/en/nwdiag",
  "pikchr" => "https://pikchr.org",
  "plantuml" => "https://plantuml.com",
  "rackdiag" => "http://blockdiag.com/en/nwdiag",
  "seqdiag" => "http://blockdiag.com/en/seqdiag",
  "structurizr" => "https://structurizr.com",
  "svgbob" => "https://ivanceras.github.io/content/Svgbob.html",
  "umlet" => "https://github.com/umlet/umlet",
  "vega" => "https://vega.github.io/vega",
  "vegalite" => "https://vega.github.io/vega-lite",
  "wavedrom" => "https://wavedrom.com",
)

for diagram_type in map(
  # The union of the values of `LIMITED_DIAGRAM_SUPPORT` corresponds to all
  # supported `Diagram` types. Converting the `Symbol`s to `String`s improves
  # readability of the `macro` bodies
  String,
  collect(Set(Iterators.flatten(values(LIMITED_DIAGRAM_SUPPORT)))),
)
  macro_name = Symbol("$(diagram_type)_str")
  macro_signature = Symbol("@$macro_name")

  diagram_url = get(DIAGRAM_DOCUMENTATION_URLS, diagram_type, "https://kroki.io/#support")

  docstring = "String literal for instantiating [`$diagram_type`]($diagram_url) [`Diagram`](@ref)s."

  @eval begin
    export $macro_signature

    @doc $docstring macro $macro_name(specification::AbstractString)
      Expr(
        :call,
        :Diagram,
        QuoteNode(Symbol($diagram_type)),
        Expr(:call, string, interpolate(specification)...),
      )
    end
  end
end

end
