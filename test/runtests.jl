module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki: Diagram, render
using Kroki.Exceptions: InvalidOutputFormatError

function testShowMethodRenders(
  diagram::Diagram,
  mime_type::AbstractString,
  render_output_format::AbstractString,
)
  @test sprint(show, mime_type, diagram) == String(render(diagram, render_output_format))
end

@testset "Kroki" begin
  @testset "`Diagram` instantiation" begin
    @testset "through keyword arguments" begin
      expected_specification = "[...]--[...]"
      expected_type = :svgbob

      diagram = Diagram(specification = expected_specification, type = expected_type)

      @test diagram.specification === expected_specification
      @test diagram.type === expected_type

      @testset "optionally accepts `options`" begin
        expected_options = Dict("key" => "value")

        diagram = Diagram(
          options = expected_options,
          specification = expected_specification,
          type = expected_type,
        )

        @test diagram.options === expected_options
        @test diagram.specification === expected_specification
        @test diagram.type === expected_type
      end
    end

    @testset "through `type` and `specification` positional arguments" begin
      expected_specification = "A -> B: C"
      expected_type = :plantuml

      diagram = Diagram(expected_type, expected_specification)

      @test diagram.specification === expected_specification
      @test diagram.type === expected_type

      @testset "optionally accepts `options`" begin
        expected_options = Dict("foo" => "bar")

        diagram = Diagram(expected_type, expected_specification; options = expected_options)

        @test diagram.options === expected_options
        @test diagram.specification === expected_specification
        @test diagram.type === expected_type
      end
    end

    @testset "through `type` positional argument with keyword arguments" begin
      @testset "providing the `path` keyword argument loads a file as the `specification" begin
        diagram_path = joinpath(@__DIR__, "assets", "plantuml-example.puml")
        expected_specification = read(diagram_path, String)

        diagram = Diagram(:plantuml; path = diagram_path)

        @test diagram.specification === expected_specification
      end

      @testset "optionally accepts `options`" begin
        expected_options = Dict("key" => "value")

        diagram =
          Diagram(:plantuml; options = expected_options, specification = "A -> B: C")

        @test diagram.options === expected_options
      end

      @testset "providing the `specification` keyword argument stores it" begin
        expected_specification = "A -> B: C"

        diagram = Diagram(:plantuml; specification = expected_specification)

        @test diagram.specification === expected_specification
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
