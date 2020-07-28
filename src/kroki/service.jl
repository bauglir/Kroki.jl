"""
Defines functions and constants managing the Kroki service the rest of the
package uses to render diagrams. These services can be either local or remote.
"""
module Service

using ..Documentation
@setupDocstringMarkup()

"""
The default [`ENDPOINT`](@ref) to use, i.e. the [publicly hosted
version](https://kroki.io).
"""
const DEFAULT_ENDPOINT = "https://kroki.io"

"The currently active Kroki service endpoint being used."
const ENDPOINT = Ref{String}("https://kroki.io")

"""
Sets the [`ENDPOINT`](@ref) using a fallback mechanism if no `endpoint` is
provided.

The fallback mechanism checks for a `KROKI_ENDPOINT` environment variable
specifying an endpoint (e.g. to be used across Julia instances). If this
environment variable is also not present the [`DEFAULT_ENDPOINT`](@ref) is
used.

This can, for instance, be used in cases where a [privately hosted
instance](https://docs.kroki.io/kroki/setup/install/) is available.

Returns the value that [`ENDPOINT`](@ref) got set to.

# Examples

- `setEndpoint!()`
- `setEndpoint!("http://localhost:8000")`
"""
function setEndpoint!(
  endpoint::AbstractString = get(ENV, "KROKI_ENDPOINT", DEFAULT_ENDPOINT)
)
  ENDPOINT[] != endpoint && @info "Setting Kroki service endpoint to $(endpoint)."
  ENDPOINT[] = String(endpoint)
end

# Ensure `ENDPOINT` has a valid value
__init__() = setEndpoint!()

end
