# The docstring is included here to ensure visibility, but needs to be stored
# in a variable and associated to the module _after_ it has been define so that
# the docstring can refer to functions defined within the module
service_module_docstring = """
Defines functions and constants managing the Kroki service the rest of the
package uses to render diagrams. These services can be either local or remote.

This module also enables management of a local service instance, provided
[Docker](https://docker.com) and [Docker
Compose](https://docs.docker.com/compose/) are available on the system.

By default, the functions managing locally running services will rely on the
`latest` tag for the [`yuzutech/kroki` container
image](https://hub.docker.com/r/yuzutech/kroki/tags). This typically means the
most recently released version of Kroki will be used. In this mode,
[`Kroki.Service.update!`](@ref) can be used to pull in the most recent version.
A `KROKI_CONTAINER_IMAGE_TAG` environment variable can be configured, prior to
invoking [`Kroki.Service.start!`](@ref), to start the services corresponding to
a specific version of Kroki. It is important the variable matches an existing
tag for the container image.

!!! warning "Changing Kroki versions"
    Changing the `KROKI_CONTAINER_IMAGE_TAG` environment variable after calling
    [`Kroki.Service.start!`](@ref) may result in manual cleanup of containers
    being necessary as the service management functions will _not_ keep track
    of which versions of services were previously started.
"""
module Service

using HTTP: get as httpget
using JSON: parse as parseJSON
using Markdown: parse as parseMarkdown

using ..Exceptions: InfoRetrievalError
using ..Kroki: toMarkdownLink

using ..Documentation
@setupDocstringMarkup()

"""
The default [`ENDPOINT`](@ref) to use, i.e. the [publicly hosted
version](https://kroki.io).
"""
const DEFAULT_ENDPOINT = "https://kroki.io"

"""
A specialized `Exception` to include reporting instructions for specific types
of errors that may occur while trying to execute `docker-compose`.
"""
struct DockerComposeExecutionError <: Exception
  message::String
end
Base.showerror(io::IO, error::DockerComposeExecutionError) = print(
  io,
  """
An error occurred while executing `docker-compose`.

This may be caused by a change in its interface. If you believe this error to
be caused by Kroki.jl itself instead of a configuration error on the system,
please file an issue through https://github.com/bauglir/Kroki.jl/issues/new
including the error message below and a description of when the error occurred.

The reported error was:

$(error.message)
""",
)

"The currently active Kroki service endpoint being used."
const ENDPOINT = Ref{String}("https://kroki.io")

"Path to the Docker Compose definitions for running a local Kroki service."
const SERVICE_DEFINITION_FILE = realpath("$(@__DIR__)/../../support/docker-services.yml")

"""
Helper function for executing Docker Compose commands.

Returns captured stdout.

Throws an `ErrorException` if Docker and/or Docker Compose aren't available.
Throws a `DockerComposeExecutionError` if any other exception occurs during
execution.
"""
function executeDockerCompose(cmd::Vector{String})
  captured_stderr = IOBuffer()
  captured_stdout = IOBuffer()

  try
    run(
      pipeline(
        `docker-compose --file $(SERVICE_DEFINITION_FILE) --project-name krokijl $cmd`;
        stderr = captured_stderr,
        stdout = captured_stdout,
      ),
    )
  catch exception
    exception isa Base.IOError && throw(
      ErrorException(
        "Missing dependencies! Docker and/or Docker Compose do not appear to be available",
      ),
    )

    throw(DockerComposeExecutionError(String(take!(captured_stderr))))
  end

  String(take!(captured_stdout))
end
executeDockerCompose(cmd::String) = executeDockerCompose([cmd])
# The function should be called through indirection in cases where it needs to
# be mocked out in tests
const EXECUTE_DOCKER_COMPOSE = Ref{Any}(executeDockerCompose)

function infoVersionOverview(
  kroki_service_version::Dict{String, Any},
  diagram_type_versions::Vector{String},
)
  return parseMarkdown(
    """
    The active Kroki service ($(ENDPOINT[])) runs
    v$(VersionNumber(kroki_service_version["number"]))
    ($(kroki_service_version["build_hash"])), which is configured with the
    following diagram type versions.

    | Diagram Type | Version |
    | :-- | :-- |
    $(join(diagram_type_versions, '\n'))

    !!! info "Diagram type availability"
        The presence of a diagram type in this list does not mean it is actually
        supported by the service at $(ENDPOINT[]). This is due to some diagram
        types requiring additional services that may not be available, as they need
        to be managed separately. See [the architecture section on Kroki's
        website](https://docs.kroki.io/kroki/architecture) for more information.
    """,
  )
end

"""
Provides an overview of the (versions of) tools supporting the different
diagram types based on information provided by the service as configured
through [`setEndpoint!`](@ref).

# Example

`julia> Kroki.Service.info()`
"""
function info()
  try
    response = httpget("$(ENDPOINT[])/health")

    versions = get(parseJSON(String(response.body)), "version", nothing)

    kroki_service_version = get(versions, "kroki", nothing)
    delete!(versions, "kroki")

    diagram_type_versions = sort([
      "| $(toMarkdownLink(Symbol(diagram_type))) | $(version) |" for
      (diagram_type, version) in versions
    ])

    return infoVersionOverview(kroki_service_version, diagram_type_versions)
  catch
    throw(InfoRetrievalError(ENDPOINT[]))
  end
end

"""
Sets the [`ENDPOINT`](@ref) using a fallback mechanism if no `endpoint` is
provided.

The fallback mechanism checks for a `KROKI_ENDPOINT` environment variable
specifying an endpoint (e.g. to be used across Julia instances). If this
environment variable is also not present the [`DEFAULT_ENDPOINT`](@ref) is
used.

This can, for instance, be used in cases where a [privately hosted
instance](https://docs.kroki.io/kroki/setup/install/) is available or when a
local service has been [`start!`](@ref)ed.

Returns the value that [`ENDPOINT`](@ref) got set to.

# Examples

- `setEndpoint!()`
- `setEndpoint!("http://localhost:8000")`
"""
function setEndpoint!(
  endpoint::AbstractString = get(ENV, "KROKI_ENDPOINT", DEFAULT_ENDPOINT),
)
  ENDPOINT[] != endpoint && @info "Setting Kroki service endpoint to $(endpoint)."
  ENDPOINT[] = String(endpoint)
end

"""
Starts the Kroki service components on the local system, optionally, ensuring
[`ENDPOINT`](@ref) points to them.

Pass `false` to the function to prevent the [`ENDPOINT`](@ref) from being
updated. The default behavior is to update.
"""
function start!(update_endpoint::Bool = true)
  @info "Starting Kroki service components."
  EXECUTE_DOCKER_COMPOSE[](["up", "--detach"])
  update_endpoint && setEndpoint!("http://localhost:8000")
  return
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
  states_to_bool = Pair{String, Bool}["running" => true, "stopped" => false]

  services_by_state = map(states_to_bool) do (state, running)::Pair{String, Bool}
    services_with_state =
      EXECUTE_DOCKER_COMPOSE[](["ps", "--filter", "status=$state", "--services"])

    service_symbols = Symbol.(split(services_with_state, '\n'; keepempty = false))

    (; [service => running for service in service_symbols]...)
  end

  merge(services_by_state...)
end

"""
Stops any running Kroki service components ensuring [`ENDPOINT`](@ref) no
longer points to the stopped service.

Cleans up left-over containers by default. This behavior can be turned off by
passing `false` to the function.
"""
function stop!(perform_cleanup::Bool = true)
  @info "Stopping Kroki service components."
  EXECUTE_DOCKER_COMPOSE[]("stop")
  perform_cleanup && EXECUTE_DOCKER_COMPOSE[](["rm", "--force"])
  setEndpoint!()
  return
end

"Updates the Docker images for the individual Kroki service components."
function update!()
  EXECUTE_DOCKER_COMPOSE[](["pull", "--quiet"])
  return
end

# Ensure `ENDPOINT` has a valid value
__init__() = setEndpoint!()

end
@doc service_module_docstring Service
