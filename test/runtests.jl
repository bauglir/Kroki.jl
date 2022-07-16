module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki: Diagram, Kroki, render
using Kroki.Exceptions: InvalidOutputFormatError, UnsupportedMIMETypeError

function testShowMethodRenders(
  diagram::Diagram,
  mime_type::MIME,
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
      @test rendered[(end - length(PNG_EOF) + 1):end] == PNG_EOF
    end

    @testset "$(diagram_format) to SVG" for (diagram_format, specification) in
                                            DIAGRAM_EXAMPLES
      rendered = String(render(Diagram(diagram_format, specification), "svg"))

      @test startswith(rendered, "<?xml")
      # Some renderers (e.g. Graphviz) include additional whitespace/newlines
      # after the render, these should be ignored when matching
      @test endswith(rendered, r"</svg>\s?")
    end

    # Vega (and Vega Lite) are some of the diagram types with working PDF
    # support. They don't match the generic SVG expectations exactly, so they
    # are not included in the overall test set of diagrams for SVG and PNG
    # above
    @testset "Vega Lite to PDF" begin
      # The PDF specification defines the structure of PDF files (see
      # https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf).
      # The most straight-forward ways to test for a rendered PDF are verifying
      # the 'file header' (defined in section 7.5.2) and the 'file trailer' EOF
      # marker (defined in section 7.5.5). In plain text these are respectively
      # `%PDF-x.y.%` and `%%EOF.`.
      #
      # Due to the variability of the version numbers in the file header the
      # following only checks for `%PDF-` in the rendered result
      PDF_HEADER = [0x25, 0x50, 0x44, 0x46, 0x2d]
      PDF_EOF = [0x25, 0x25, 0x45, 0x4f, 0x46, 0x0a]

      vegalite_specification = """
      {
        "data": { "values": [ {"a": 28}, {"a": 55}, {"a": 23 } ] },
        "mark": "circle",
        "encoding": { "y": { "field": "a", "type": "nominal" }  }
      }
      """

      rendered = render(Diagram(:vegalite, vegalite_specification), "pdf")

      @test rendered[1:length(PDF_HEADER)] == PDF_HEADER
      @test rendered[(end - length(PDF_EOF) + 1):end] == PDF_EOF
    end

    @testset "takes `options` into account" begin
      expected_theme_name = "materia"
      options = Dict{String, String}("theme" => expected_theme_name)
      diagram = Diagram(:plantuml, "A -> B: C"; options)

      @testset "defaults to `Diagram` options" begin
        rendered = String(render(diagram, "svg"))

        @test occursin("!theme $(expected_theme_name)", rendered)
      end

      @testset "allows definition at render-time" begin
        expected_overridden_theme = "sketchy"
        rendered = String(
          render(diagram, "svg"; options = Dict("theme" => expected_overridden_theme)),
        )

        @test occursin("!theme $(expected_overridden_theme)", rendered)
      end
    end
  end

  @testset "`Base.show`" begin
    # Svgbob diagrams only support SVG output. Any other formats should throw
    # `InvalidOutputFormatError`s when called directly.
    #
    # To prevent compatible `AbstractDisplay`s from trying to render
    # incompatible diagram types to unsuppored output formats, `Base.showable`
    # should be overridden to indicate the diagram cannot be rendered in the
    # specified MIME type
    svgbob_diagram = Diagram(:svgbob, "-->[_...__... ]")
    @test_throws(
      InvalidOutputFormatError,
      show(IOBuffer(), MIME"application/pdf"(), svgbob_diagram)
    )
    @test !showable("application/pdf", svgbob_diagram)
    @test_throws(InvalidOutputFormatError, sprint(show, MIME"image/png"(), svgbob_diagram))
    @test !showable(MIME"image/png"(), svgbob_diagram)
    @test_throws(
      InvalidOutputFormatError,
      show(IOBuffer(), MIME"image/jpeg"(), svgbob_diagram)
    )
    @test !showable("image/jpeg", svgbob_diagram)
    testShowMethodRenders(svgbob_diagram, MIME"image/svg+xml"(), "svg")
    @test !showable("non-existent/mime-type", svgbob_diagram)

    plantuml_diagram = Diagram(:PlantUML, "A -> B: C")
    testShowMethodRenders(plantuml_diagram, MIME"image/png"(), "png")
    testShowMethodRenders(plantuml_diagram, MIME"image/svg+xml"(), "svg")

    @testset "`text/plain`" begin
      @testset "without ASCII/Unicode rendering support" begin
        # These diagram types should simply display their `specification`
        @test sprint(show, MIME"text/plain"(), svgbob_diagram) ==
              svgbob_diagram.specification
      end

      @testset "with ASCII/Unicode rendering support" begin
        # PlantUML and Structurizr diagrams can be rendered nicely in
        # text/plain based environments. Their exact appearance can be
        # controlled using the `TEXT_PLAIN_SHOW_MIME_TYPE` variable by
        # indicating adding a `charset` to the MIME type indicating Unicode
        # support
        original_text_plain_mimetype = Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[]

        Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = MIME"text/plain; charset=utf-8"()
        testShowMethodRenders(plantuml_diagram, MIME"text/plain"(), "utxt")

        Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = MIME"text/plain"()
        testShowMethodRenders(plantuml_diagram, MIME"text/plain"(), "txt")

        @testset "generates an error if an invalid `text/plain` MIME type is configured" begin
          Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = MIME"image/png"()

          @test_throws(
            UnsupportedMIMETypeError,
            show(IOBuffer(), MIME"text/plain"(), plantuml_diagram)
          )
        end

        Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = original_text_plain_mimetype
      end
    end
  end

  # Include the test suites for all submodules
  include.(readdir(joinpath(@__DIR__, "kroki"); join = true))
end

end
