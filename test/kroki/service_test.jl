module ServiceTest

using Kroki.Service: DEFAULT_ENDPOINT, DockerComposeExecutionError, ENDPOINT,
                     EXECUTE_DOCKER_COMPOSE, executeDockerCompose,
                     setEndpoint!, status
using SimpleMock
using Test: @testset, @test, @test_logs

# Helper function to temporarily replace `EXECUTE_DOCKER_COMPOSE` with a
# `Mock`. Used to gain control over `docker-compose` behavior for local service
# instance management tests
function mockExecuteDockerCompose(f::Function, mock::Mock)
  EXECUTE_DOCKER_COMPOSE[] = mock
  f(mock)
  EXECUTE_DOCKER_COMPOSE[] = executeDockerCompose
end

@testset "Service" begin
  @testset "`ENDPOINT`" begin
    # Keep track of the original endpoint, so it can later be restored after
    # all tests have finished running. This should be robust with respect to
    # errors in the inner `TestSet`s
    original_endpoint = ENDPOINT[]

    @testset "`setEndpoint!`" begin
      @testset "with `endpoint` adjusts `ENDPOINT` to `endpoint`" begin
        expected_endpoint = "http://specific.endpoint.jl"

        setEndpoint!(expected_endpoint)

        @test ENDPOINT[] === expected_endpoint
      end

      @testset "without `endpoint` adjusts `ENDPOINT` to" begin
        @testset "`KROKI_ENDPOINT` environment variable if set" begin
          expected_endpoint = "http://from.environment.jl"
          withenv("KROKI_ENDPOINT" => expected_endpoint) do
            setEndpoint!()
            @test ENDPOINT[] === expected_endpoint
          end
        end

        @testset "`DEFAULT_ENDPOINT` otherwise" begin
          # Force the `KROKI_ENDPOINT` environment variable to be unset, as it
          # may be set outside the scope of the tests which would cause this
          # test to fail
          withenv("KROKI_ENDPOINT" => nothing) do
            setEndpoint!()
            @test ENDPOINT[] === DEFAULT_ENDPOINT
          end
        end
      end

      @testset "logs `ENDPOINT` updates only if changed" begin
        expected_endpoint = "http://logged.endpoint.jl"

        @test_logs (:info, "Setting Kroki service endpoint to $(expected_endpoint).") setEndpoint!(expected_endpoint)
        @test_logs setEndpoint!(expected_endpoint)
      end
    end

    # Restore the original endpoint
    ENDPOINT[] = original_endpoint
  end

  @testset "local instance management" begin
    @testset "`executeDockerCompose` throws descriptive errors" begin
      @testset "indicating dependencies are missing" begin
        try
          # Breaking the path should ensure neither Docker, nor Docker Compose
          # can be found
          withenv(() -> executeDockerCompose("ps"), "PATH" => nothing)
        catch exception
          @test exception isa ErrorException

          error_message = sprint(showerror, exception)
          @test startswith(error_message, "Missing dependencies!")
          @test occursin("Docker Compose", error_message)
        end
      end

      @testset "indicating to file an issue on indications of errors in Kroki.jl" begin
        try
          executeDockerCompose(["--non-existent", "ps"])
        catch exception
          @test exception isa DockerComposeExecutionError

          error_message = sprint(showerror, exception)
          @test occursin("docker-compose", error_message)
          @test occursin("file an issue", error_message)
          @test occursin("The reported error was", error_message)
        end
      end
    end

    @testset "`status` reports individual Kroki service component status" begin
      status_mock = Mock((cmd::Vector{String}) -> (
        any(cmd .== "status=running")
        ? """
          core
          blockdiag
          mermaid
          """
        : "bpmn"
      ))

      mockExecuteDockerCompose(status_mock) do _executeDockerCompose
        service_statuses = status()

        @test service_statuses.core
        @test service_statuses.blockdiag
        @test !service_statuses.bpmn
        @test service_statuses.mermaid

        @test called_with(
          _executeDockerCompose,
          ["ps", "--filter", "status=running", "--services"]
        )
        @test called_with(
          _executeDockerCompose,
          ["ps", "--filter", "status=stopped", "--services"]
        )
      end
    end
  end
end

end
