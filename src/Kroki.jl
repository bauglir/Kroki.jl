module Kroki

using Base64: base64encode
using CodecZlib: ZlibCompressor, transcode
using HTTP: request

"""
A representation of a diagram that can be rendered by a Kroki service. The
specification of the diagram type, which is captured as a `Symbol` in the
type's parameter, is case-insensitive!

# Examples

```
Diagram{Val{:PlantUML}}("Kroki -> Julia: Hello Julia!")
```
"""
struct Diagram{Val}
  "The textual specification of the diagram"
  specification::AbstractString

  function Diagram{T}(specification::AbstractString) where T <: Val
    @assert T.parameters[1] isa Symbol
    new(specification)
  end
end

"""
Shorthand for constructing a [`Diagram`](@ref) without having to specify its
parametric part.
"""
Diagram(type::Symbol, specification::AbstractString) = Diagram{Val{type}}(specification)

"""
An `Exception` to be thrown when a [`Diagram`](@ref) representing an invalid
specification is passed to [`render`](@ref).
"""
struct InvalidDiagramSpecificationError <: Exception
  error::String
  cause::Diagram
end

function Base.showerror(io::IO, error::InvalidDiagramSpecificationError)
  diagram_type = typeof(error.cause).parameters[1].parameters[1]

  print(io, """
  The Kroki service responded with:
  $(error.error)

  In response to a '$(diagram_type)' diagram with the specification:
  $(error.cause.specification)

  This is (likely) caused by an invalid diagram specification.
  """)
end

"""
Compresses a [`Diagram`](@ref)'s `specification` using
[zlib](https://zlib.net), turning the resulting bytes into a URL-safe Base64
encoded payload (i.e. replacing `+` by `-` and `/` by `_`) to be used in
communication with a Kroki service.

See https://docs.kroki.io/kroki/setup/encode-diagram/ for more information.
"""
UriSafeBase64Payload(diagram::Diagram) = foldl(
  replace, [ '+' => '-', '/' => '_'];
  init = base64encode(transcode(ZlibCompressor, diagram.specification))
)

"""
Renders a [`Diagram`](@ref) through a Kroki service to the specified output
format.
"""
render(diagram::Diagram{T}, output_format::AbstractString) where T <: Val = try
  getfield(
    request("GET", join([
      "https://kroki.io",
      lowercase("$(T.parameters[1])"),
      output_format,
      UriSafeBase64Payload(diagram)
    ], '/')),
    :body
  )
catch exception
  if exception.status == 400
    throw(InvalidDiagramSpecificationError(
      String(exception.response.body), diagram
    ))
  else
    throw(exception)
  end
end

end
