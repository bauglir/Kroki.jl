module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki:
  Diagram,
  DiagramPathOrSpecificationError,
  InvalidDiagramSpecificationError,
  InvalidOutputFormatError,
  StatusError, # Imported from HTTP through Kroki
  render
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

function testShowMethodRenders(
  diagram::Diagram,
  mime_type::AbstractString,
  render_output_format::AbstractString,
)
  @test sprint(show, mime_type, diagram) == String(render(diagram, render_output_format))
end

@testset "Kroki" begin
  @testset "`Diagram` instantiation providing" begin
    @testset "`path` loads the file as the `specification" begin
      diagram_path = joinpath(@__DIR__, "assets", "plantuml-example.puml")
      expected_specification = read(diagram_path, String)

      diagram = Diagram(:plantml; path = diagram_path)

      @test diagram.specification === expected_specification
    end

    @testset "`specification` stores it" begin
      expected_specification = "A -> B: C"

      diagram = Diagram(:plantuml; specification = expected_specification)

      @test diagram.specification === expected_specification
    end

    @testset "invalid `path`/`specification` combinations errors" begin
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

  @testset "`render`" begin
    # This is not an exhaustive list of supported diagram types or output
    # formats, but serves to verify generic rendering logic is available for at
    # least the specified types and output formats
    DIAGRAM_EXAMPLES = [
      :PlantUML => "Kroki -> Julia: Hello",
      :Graphviz => "digraph D { Hello->World }",
      :ditaa => """
      +--------+     +---------+
      |        |     |         |
      |  User  | <-> | Another |
      |        |     |    User |
      |        |     |         |
      +--------+     +---------+
      """,
      # The specification of the diagram type is case-insensitive
      :plantuml => "Kroki <- Julia: Hello",
    ]

    # The PNG specification defines the structure of PNG files (see
    # http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html). The most
    # straight-forward parts to test for are the header and the end-of-file
    # marker (i.e. the 'IEND image trailer'), both consisting of 8 bytes
    PNG_HEADER = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
    PNG_EOF = [0x0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]
    @testset "$(diagram_format) to PNG" for (diagram_format, specification) in
                                            DIAGRAM_EXAMPLES
      rendered = render(Diagram(diagram_format, specification), "png")

      @test rendered[1:length(PNG_HEADER)] == PNG_HEADER
      @test rendered[(end - 8):end] == PNG_EOF
    end

    @testset "$(diagram_format) to SVG" for (diagram_format, specification) in
                                            DIAGRAM_EXAMPLES
      rendered = String(render(Diagram(diagram_format, specification), "svg"))

      @test startswith(rendered, "<?xml")
      # Some renderers (e.g. Graphviz) include additional whitespace/newlines
      # after the render, these should be ignored when matching
      @test endswith(rendered, r"</svg>\s?")
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
          @test occursin(
            "$(expected_service_host)/$(expected_diagram_type)",
            rendered_buffer,
          )
        end

        setEndpoint!()
      end
    end
  end

  @testset "`Base.show`" begin
    # Svgbob diagrams only support SVG output. Any other formats should throw
    # `InvalidOutputFormatError`s when called directly.
    #
    # To prevent compatible `AbstractDisplay`s from trying to render
    # incompatible diagram types in certain formats resulting in errors,
    # `Base.showable` should be overridden to indicate the diagram cannot be
    # rendered in the specified MIME type
    svgbob_diagram = Diagram(:svgbob, "-->[_...__... ]")
    @test_throws(InvalidOutputFormatError, sprint(show, "image/png", svgbob_diagram))
    @test !showable("image/png", svgbob_diagram)
    testShowMethodRenders(svgbob_diagram, "image/svg+xml", "svg")

    plantuml_diagram = Diagram(:PlantUML, "A -> B: C")
    testShowMethodRenders(plantuml_diagram, "image/png", "png")
    testShowMethodRenders(plantuml_diagram, "image/svg+xml", "svg")

    @testset "`text/plain`" begin
      # PlantUML diagrams can be rendered nicely in text/plain based
      # environments
      testShowMethodRenders(plantuml_diagram, "text/plain", "utxt")

      # Other diagram types should simply display their `specification`
      @test sprint(show, "text/plain", svgbob_diagram) == svgbob_diagram.specification
    end
  end

  # Include the test suites for all submodules
  include.(readdir(joinpath(@__DIR__, "kroki"); join = true))
end

end
