"""
The main `Module` containing the necessary types of functions for integration
with a Kroki service.

Defines `Base.show` and corresponding `Base.showable` methods for different
output formats and [`Diagram`](@ref Kroki.Diagram) types, so they render in
their most optimal form in different environments (e.g. the documentation
system, Documenter output, Jupyter, etc.).
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
  "The textual specification of the diagram"
  specification::AbstractString

  """
  The type of diagram specification (e.g. ditaa, Mermaid, PlantUML, etc.). This
  value is case-insensitive.
  """
  type::Symbol

  Diagram(type::Symbol, specification::AbstractString) = new(specification, type)
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

If the Kroki service responds with an error throws an
[`InvalidDiagramSpecificationError`](@ref) or
[`InvalidOutputFormatError`](@ref) if a know type of error occurs. Other errors
(e.g. `HTTP.ExceptionRequest.StatusError` for connection errors) are propagated
if they occur.
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
    :umlet,
    :vega,
    :vegalite,
  ),
  # Although all diagram types support SVG, these _only_ support SVG so are
  # included separately
  "image/svg+xml" => (:nomnoml, :svgbob, :wavedrom),
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

for diagram_type in map(
  # The union of the values of `LIMITED_DIAGRAM_SUPPORT` corresponds to all
  # supported `Diagram` types. Converting the `Symbol`s to `String`s improves
  # readability of the `macro` bodies
  String,
  collect(Set(Iterators.flatten(values(LIMITED_DIAGRAM_SUPPORT)))),
)
  macro_name = Symbol("$(diagram_type)_str")
  macro_signature = Symbol("@$macro_name")

  docstring = "Shorthand for instantiating $diagram_type [`Diagram`](@ref)s."

  @eval begin
    export $macro_signature

    @doc $docstring macro $macro_name(specification::AbstractString)
      Expr(
        :call,
        :Diagram,
        QuoteNode(Symbol($diagram_type)),
        Expr(:call, string, interpolate(specification)...)
      )
    end
  end
end

end
