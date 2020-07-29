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

"Path to the Docker Compose definitions for running a local Kroki service."
const SERVICE_DEFINITION_FILE = realpath(
  "$(@__DIR__)/../../support/docker-services.yml"
)

"Helper function for executing Docker Compose commands."
function executeDockerCompose(cmd::Vector{String})
  captured_stdout = IOBuffer()

  run(pipeline(
    `docker-compose --file $(SERVICE_DEFINITION_FILE) --project-name krokijl $cmd`;
    stdout = captured_stdout
  ))

  String(take!(captured_stdout))
end
executeDockerCompose(cmd::String) = executeDockerCompose([cmd])
# The function should be called through indirection in cases where it needs to
# be mocked out in tests
const EXECUTE_DOCKER_COMPOSE = Ref{Any}(executeDockerCompose)

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

"""
Returns a `NamedTuple` where the keys are the names of the service components
and the values their corresponding 'running' state.

# Examples
```
julia> status()
(core = true, mermaid = false)
```
"""
function status()
  states_to_bool = Pair{String,Bool}["running" => true, "stopped" => false]

  services_by_state = map(states_to_bool) do (state, running)::Pair{String,Bool}
    services_with_state = EXECUTE_DOCKER_COMPOSE[](
      ["ps", "--filter", "status=$state", "--services"]
    )

    service_symbols = Symbol.(
      split(services_with_state, '\n'; keepempty = false)
    )

    (; zip(service_symbols, Iterators.repeated(running))... )
  end

  merge(services_by_state...)
end

# Ensure `ENDPOINT` has a valid value
__init__() = setEndpoint!()

end
