module ExceptionsTest

using Test: @test, @test_throws, @testset

using Kroki: Diagram, render
using Kroki.Exceptions:
  DiagramPathOrSpecificationError,
  InvalidDiagramSpecificationError,
  InvalidOutputFormatError,
  StatusError # Imported from HTTP through Kroki
using Kroki.Service: setEndpoint!

testRenderError(
  title::AbstractString,
  diagram_type::Symbol,
  content::AbstractString,
  output_format::AbstractString,
  expected_error_type::DataType,
) = @testset "$(title)" begin
  diagram = Diagram(diagram_type, content)

  @test_throws(expected_error_type, render(diagram, output_format))

  @testset "rendering" begin
    service_response = "$(title) response"

    rendered_error = sprint(showerror, expected_error_type(service_response, diagram))

    @test occursin("Kroki service responded with:", rendered_error)
    @test occursin(content, rendered_error)
    @test occursin(service_response, rendered_error)
  end
end

@testset "exceptions" begin
  @testset "invalid `Diagram` instantiation" begin
    @testset "with invalid `path`/`specification` combinations errors" begin
      @testset "specifying both" begin
        @test_throws(
          DiagramPathOrSpecificationError,
          Diagram(:mermaid; path = tempname(), specification = "A -> B: C")
        )
      end

      @testset "specifying neither" begin
        @test_throws(DiagramPathOrSpecificationError, Diagram(:svgbob))
      end

      @testset "rendering" begin
        expected_specification = "X -> Y: Z"

        rendered_error =
          sprint(showerror, DiagramPathOrSpecificationError(nothing, "X -> Y: Z"))

        @test startswith(
          rendered_error,
          "Either `path` or `specification` should be specified:",
        )
        @test occursin("* `path`: '<not specified>'", rendered_error)
        @test occursin("* `specification`: '$(expected_specification)'", rendered_error)
      end
    end
  end

  @testset "`RenderError`" begin
    # `RenderError`s are thrown from the `render` function whenever an error
    # occurs. Some of these benefit from rewrites into more descriptive
    # errors
    @testset "transforms rewritable `HTTP.ExceptionRequest.StatusError`s" begin
      # Errors in the Kroki service are thrown as
      # `HTTP.ExceptionRequest.StatusError` and should be rewritten in more
      # descriptive errors
      testRenderError(
        "invalid diagram specification",
        :PlantUML,
        # A missing `>` and message cause the specification to be invalid
        "Julia - Kroki:",
        "svg",
        InvalidDiagramSpecificationError,
      )

      testRenderError(
        "invalid output format",
        :Mermaid,
        # The Mermaid renderer does not support PNG output
        "graph TD; A --> B;",
        "jpeg",
        InvalidOutputFormatError,
      )
    end

    @testset "passes unknown `HTTP.ExceptionRequest.StatusError`s as-is" begin
      # Any HTTP related errors that are not due to rendering errors in the
      # Kroki service (e.g. unknown endpoints), should be thrown from
      # `RenderError` as-is
      @test_throws(StatusError, render(Diagram(:non_existent_diagram_type, ""), "svg"))
    end

    @testset "passes other errors as-is" begin
      # Non-`StatusError`s (e.g. `IOError`s due to incorrect hostnames should
      # be thrown/returned as-is
      expected_service_host = "http://localhost:1"
      expected_diagram_type = :plantuml
      setEndpoint!(expected_service_host)

      try
        render(Diagram(expected_diagram_type, "A -> B: C"), "svg")
      catch exception
        rendered_buffer = sprint(showerror, exception)

        @test occursin("ECONNREFUSED", rendered_buffer)
        @test occursin("$(expected_service_host)/$(expected_diagram_type)", rendered_buffer)
      end

      setEndpoint!()
    end
  end
end

end
