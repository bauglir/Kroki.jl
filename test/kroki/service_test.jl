module ServiceTest

using Kroki.Service: DEFAULT_ENDPOINT, ENDPOINT, setEndpoint!
using Test: @testset, @test, @test_logs

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
end

end
