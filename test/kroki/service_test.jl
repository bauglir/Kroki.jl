module ServiceTest

using Kroki.Service:
  DEFAULT_ENDPOINT,
  DockerComposeExecutionError,
  ENDPOINT,
  EXECUTE_DOCKER_COMPOSE,
  executeDockerCompose,
  setEndpoint!,
  start!,
  status,
  stop!,
  update!
using SimpleMock
using Test: @testset, @test, @test_logs, @test_skip

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

        @test_logs (:info, "Setting Kroki service endpoint to $(expected_endpoint).") setEndpoint!(
          expected_endpoint,
        )
        @test_logs setEndpoint!(expected_endpoint)
      end
    end

    # Restore the original endpoint
    ENDPOINT[] = original_endpoint
  end

  @testset "local instance management" begin
    @testset "`executeDockerCompose` throws descriptive errors indicating" begin
      @testset "dependencies are missing" begin
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

      # These tests require `docker-compose` to be available, as they
      # specifically test errors in the interface from Kroki.jl to it.
      #
      # This construct ensures the tests are always run if possible and clearly
      # marked broken on unsupported platforms
      @static if Sys.which("docker-compose") !== nothing
        @testset "to file an issue on indications of errors in Kroki.jl" begin
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
      else
        @test_skip "Tests requiring `docker-compose` are skipped"
      end
    end

    @testset "`start!` starts Kroki service components" begin
      # The `start!` function adjusts the `ENDPOINT` so the started Kroki
      # service is immediately ready for use. This needs to be restored
      original_endpoint = ENDPOINT[]

      @testset "updating the `ENDPOINT` by default" begin
        mockExecuteDockerCompose(Mock()) do _executeDockerCompose
          # Set the `ENDPOINT` to a known value specific to the test, so it can
          # be detected that `start!` modifies it's value
          unstarted_instance_endpoint = "http://unstarted.instance.jl"
          setEndpoint!(unstarted_instance_endpoint)
          @test ENDPOINT[] === unstarted_instance_endpoint

          # The following explicitly uses `match_mode=:any` to prevent having
          # to specify log messages caused by changes to `ENDPOINT`
          returned = @test_logs (:info, "Starting Kroki service components.") match_mode =
            :any start!()

          # Ensure nothing gets returned from a call to `start!` instead of
          # `Process`es from the `docker-compose` execution
          @test returned === nothing
          @test called_with(_executeDockerCompose, ["up", "--detach"])

          @test ENDPOINT[] == "http://localhost:8000"
        end
      end

      @testset "while not updating `ENDPOINT` if asked" begin
        mockExecuteDockerCompose(Mock()) do _executeDockerCompose
          # Set the `ENDPOINT` to a known value specific to the test, so it can
          # be detected that `start!` modifies it's value
          non_modified_endpoint = "http://non.modified.endpoint.jl"
          setEndpoint!(non_modified_endpoint)
          @test ENDPOINT[] === non_modified_endpoint

          # Instruct `start!` to _not_ update the `ENDPOINT`
          start!(false)

          @test ENDPOINT[] === non_modified_endpoint
        end
      end

      ENDPOINT[] = original_endpoint
    end

    @testset "`status` reports individual Kroki service component status" begin
      status_mock = Mock((cmd::Vector{String}) -> (any(cmd .== "status=running") ? """
                                                                                   core
                                                                                   blockdiag
                                                                                   mermaid
                                                                                   """ : "bpmn"))

      mockExecuteDockerCompose(status_mock) do _executeDockerCompose
        service_statuses = status()

        @test service_statuses.core
        @test service_statuses.blockdiag
        @test !service_statuses.bpmn
        @test service_statuses.mermaid

        @test called_with(
          _executeDockerCompose,
          ["ps", "--filter", "status=running", "--services"],
        )
        @test called_with(
          _executeDockerCompose,
          ["ps", "--filter", "status=stopped", "--services"],
        )
      end
    end

    @testset "`stop!` stops any running Kroki service components" begin
      # The `stop!` function adjusts the `ENDPOINT` to ensure it doesn't point
      # to a stopped local Kroki service
      original_endpoint = ENDPOINT[]

      mockExecuteDockerCompose(Mock()) do _executeDockerCompose
        # Set the `ENDPOINT` to a known value specific to the test, so it can
        # be detected that `stop!` modifies it's value
        local_instance_endpoint = "http://local.instance.jl"
        setEndpoint!(local_instance_endpoint)
        @test ENDPOINT[] === local_instance_endpoint

        # The following explicitly uses `match_mode=:any` to prevent having to
        # specify log messages caused by changes to `ENDPOINT`
        returned = @test_logs (:info, "Stopping Kroki service components.") match_mode =
          :any stop!()

        # Ensure nothing gets returned from a call to `stop!` instead of
        # `Process`es from the `docker-compose` execution
        @test returned === nothing
        @test called_with(_executeDockerCompose, "stop")
        @test called_with(_executeDockerCompose, ["rm", "--force"])

        # The `ENDPOINT` should have been updated to the 'default' (which can
        # be either the `KROKI_ENDPOINT` environment variable of the
        # `DEFAULT_ENDPOINT`
        @test ENDPOINT[] !== local_instance_endpoint
      end

      @testset "optionally without cleaning up containers" begin
        mockExecuteDockerCompose(Mock()) do _executeDockerCompose
          # Ensure nothing gets returned from a call to `stop!` instead of
          # `Process`es from the `docker-compose` execution
          @test stop!(false) === nothing
          @test called_once_with(_executeDockerCompose, "stop")
        end
      end

      ENDPOINT[] = original_endpoint
    end

    @testset "`update!` pulls Kroki service component Docker images" begin
      mockExecuteDockerCompose(Mock()) do _executeDockerCompose
        # Ensure nothing gets returned from a call to `update!` instead of
        # `Process`es from the `docker-compose` execution
        @test update!() === nothing
        @test called_with(_executeDockerCompose, ["pull", "--quiet"])
      end
    end
  end
end

end
