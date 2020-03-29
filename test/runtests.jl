module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki: Diagram, InvalidDiagramSpecificationError,
             InvalidOutputFormatError, render

testRenderError(
  title::AbstractString,
  diagram_type::Symbol,
  content::AbstractString,
  output_format::AbstractString,
  expected_error_type::DataType
) = @testset "$(title)" begin
  diagram = Diagram(diagram_type, content)

  @test_throws(expected_error_type, render(diagram, output_format))

  @testset "rendering" begin
    service_response = "$(title) response"
    captured_error = IOBuffer()

    Base.showerror(
      captured_error,
      expected_error_type(service_response, diagram)
    )

    rendered_error = String(take!(captured_error))

    @test occursin("Kroki service responded with:", rendered_error)
    @test occursin(content, rendered_error)
    @test occursin(service_response, rendered_error)
  end
end

@testset "Kroki" begin
  @testset "`Diagram`" begin
    @testset "requires `Symbol` parameter" begin
      @test_nowarn Diagram{Val{:Foo}}("")
      @test_throws(AssertionError, Diagram{Val{1}}(""))
    end

    @testset "shorthand automatically parameterizes type" begin
      content = "A -> B: C"
      type = :PlantUML

      @test Diagram(type, content) === Diagram{Val{type}}(content)
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
      :plantuml => "Kroki <- Julia: Hello"
    ]

    # The PNG specification defines the structure of PNG files (see
    # http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html). The most
    # straight-forward parts to test for are the header and the end-of-file
    # marker (i.e. the 'IEND image trailer'), both consisting of 8 bytes
    PNG_HEADER = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
    PNG_EOF = [0x0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]
    @testset "$(diagram_format) to PNG" for (diagram_format, specification) = DIAGRAM_EXAMPLES
      rendered = render(Diagram{Val{diagram_format}}(specification), "png")

      @test rendered[1:length(PNG_HEADER)] == PNG_HEADER
      @test rendered[end-8:end] == PNG_EOF
    end

    @testset "$(diagram_format) to SVG" for (diagram_format, specification) = DIAGRAM_EXAMPLES
      rendered = String(render(Diagram{Val{diagram_format}}(specification), "svg"))

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
        InvalidDiagramSpecificationError
      )

      testRenderError(
        "invalid output format",
        :Mermaid,
        # The Mermaid renderer does not support PNG output
        "graph TD; A --> B;",
        "png",
        InvalidOutputFormatError
      )
    end
  end
end

end
