"""
Defines all custom `Exceptions` that can be thrown by different parts of the
package along with their corresponding `Base.showerror` overloads.
"""
module Exceptions

using HTTP.ExceptionRequest: StatusError

using ..Kroki: Diagram, Kroki, Maybe

using ..Documentation
@setupDocstringMarkup()

"""
An `Exception` to be thrown when the `path` and `specification` keyword
arguments to [`Diagram`](@ref) are not specified mutually exclusive.
"""
struct DiagramPathOrSpecificationError <: Exception
  "The `path` keyword argument passed to the [`Diagram`](@ref)."
  path::Maybe{AbstractString}

  "The `specification` keyword argument passed to the [`Diagram`](@ref)."
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
specification is passed to [`render`](@ref Kroki.render).
"""
struct InvalidDiagramSpecificationError <: Exception
  """
  The error message returned by the Kroki service causing the exception to be
  thrown.
  """
  error::String

  "The [`Diagram`](@ref) that caused the error."
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
An `Exception` to be thrown when a [`Diagram`](@ref) is [`render`](@ref
Kroki.render)ed to an unsupported or invalid output format.
"""
struct InvalidOutputFormatError <: Exception
  """
  The error message returned by the Kroki service causing the exception to be
  thrown.
  """
  error::String

  "The [`Diagram`](@ref) that caused the error."
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
An `Exception` to be thrown when the `selected_mime_type` is not an element of
the set of `supported_mime_types`.
"""
struct UnsupportedMIMETypeError <: Exception
  "The selected `MIME` type that is not supported."
  selected_mime_type::MIME

  "The set of supported `MIME` types."
  supported_mime_types::Set{MIME}
end

Base.showerror(io::IO, error::UnsupportedMIMETypeError) = join(
  io,
  [
    "The selected `MIME` type must be one of `",
    join(error.supported_mime_types, "`, `", "` or `"),
    "`. Got `",
    error.selected_mime_type,
    "`.",
  ],
)

end
