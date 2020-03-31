module Kroki

using Base64: base64encode
using CodecZlib: ZlibCompressor, transcode
using DocStringExtensions
using HTTP: request
using HTTP.ExceptionRequest: StatusError

@template (FUNCTIONS, METHODS, MACROS) = """
$(TYPEDSIGNATURES)
$(DOCSTRING)
"""

"""
A representation of a diagram that can be rendered by a Kroki service.

$(TYPEDFIELDS)

# Examples

```
Diagram(:PlantUML, "Kroki -> Julia: Hello Julia!")
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

Base.showerror(io::IO, error::InvalidDiagramSpecificationError) = print(io,
  """
  $(RenderErrorHeader(error))

  This is (likely) caused by an invalid diagram specification.
  """
)

"""
An `Exception` to be thrown when a [`Diagram`](@ref) is [`render`](@ref)ed to
an unsupported or invalid output format.
"""
struct InvalidOutputFormatError <: Exception
  error::String
  cause::Diagram
end

Base.showerror(io::IO, error::InvalidOutputFormatError) = print(io,
  """
  $(RenderErrorHeader(error))

  This is (likely) caused by an invalid or unknown output format.
  """
)

# Helper function to render common headers when showing render errors
function RenderErrorHeader(
  error::Union{InvalidDiagramSpecificationError, InvalidOutputFormatError}
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
  replace, [ '+' => '-', '/' => '_'];
  init = base64encode(transcode(ZlibCompressor, diagram.specification))
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

A `KROKI_ENDPOINT` environment variable can be set, specifying the URI of a
specific instance of Kroki to use (e.g. when using a [privately hosted
instance](https://docs.kroki.io/kroki/setup/install/)). By default the
[publicly hosted service](https://kroki.io) is used.
"""
render(diagram::Diagram, output_format::AbstractString) = try
  getfield(
    request("GET", join([
      get(ENV, "KROKI_ENDPOINT", "https://kroki.io"),
      lowercase("$(diagram.type)"),
      output_format,
      UriSafeBase64Payload(diagram)
    ], '/')),
    :body
  )
catch exception
  throw(RenderError(diagram, exception))
end

end
