module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki:
  @mermaid_str,
  @plantuml_str,
  Diagram,
  InvalidDiagramSpecificationError,
  InvalidOutputFormatError,
  render

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
    captured_error = IOBuffer()

    Base.showerror(captured_error, expected_error_type(service_response, diagram))

    rendered_error = String(take!(captured_error))

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
  output = IOBuffer()
  Base.show(output, mime_type, diagram)
  rendered_output = String(take!(output))

  @test rendered_output == String(render(diagram, render_output_format))
end

@testset "Kroki" begin
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

    @testset "errors" begin
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
        "png",
        InvalidOutputFormatError,
      )
    end

    @testset "`KROKI_ENDPOINT` environment variable" begin
      # The instance of the Kroki service that is used for rendering can be
      # controlled through the `KROKI_ENDPOINT` environment variable. The most
      # straight-forward way for testing this is by pointing to an invalid
      # endpoint and testing for a corresponding connection error
      expected_diagram_type = :plantuml
      expected_service_host = "https://localhost"

      withenv("KROKI_ENDPOINT" => expected_service_host) do
        try
          render(Diagram(expected_diagram_type, "A -> B: C"), "svg")
        catch exception
          buffer = IOBuffer()
          showerror(buffer, exception)
          rendered_buffer = String(take!(buffer))

          @test occursin("ECONNREFUSED", rendered_buffer)
          @test occursin(
            "$(expected_service_host)/$(expected_diagram_type)",
            rendered_buffer,
          )
        end
      end
    end
  end

  @testset "string literal shorthand for diagram types" begin
    # String literal macros should be defined as a convenient way for
    # specifying diagrams.
    #
    # This is not an exhaustive test as these are dynamically generated. The
    # basic functionality is only verified for key diagram types.
    shorthand_plantuml = plantuml"A -> B: C"
    longhand_plantuml = Diagram(:PlantUML, "A -> B: C")
    # The leading newlines make sure the alignment of the plain text
    # representations is identical across both calling methods
    @test "\n$shorthand_plantuml" == "\n$longhand_plantuml"

    shorthand_mermaid = mermaid"graph TD; A --> B"
    longhand_mermaid = Diagram(:mermaid, "graph TD; A --> B")
    @test shorthand_mermaid == longhand_mermaid
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
    @test_throws(
      InvalidOutputFormatError,
      Base.show(IOBuffer(), "image/png", svgbob_diagram)
    )
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
      output = IOBuffer()
      Base.show(output, "text/plain", svgbob_diagram)
      rendered_output = String(take!(output))

      @test rendered_output == svgbob_diagram.specification
    end
  end
end

end
