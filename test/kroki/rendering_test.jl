module RenderingTest

using Test: @test, @testset, @test_throws

using Kroki: Diagram, Kroki, overrideShowable, render, resetShowableOverrides
using Kroki.Exceptions: InvalidOutputFormatError, UnsupportedMIMETypeError

PDF_MIME_TYPE = MIME"application/pdf"()
PNG_MIME_TYPE = MIME"image/png"()
SVG_MIME_TYPE = MIME"image/svg+xml"()

function testShowMethodRenders(
  diagram::Diagram,
  mime_type::MIME,
  render_output_format::AbstractString,
)
  @test sprint(show, mime_type, diagram) == String(render(diagram, render_output_format))
end

@testset "Rendering" begin
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

      # All renderers include some metadata before the actual SVG data. For
      # instance, processing instructions, i.e. elements starting with `<?`,
      # declarations and/or comments, i.e. elements starting with `<!`. The
      # elements differ per renderer and some are separated by newlines, they
      # should all be ignored for testing purposes. The important bit is a
      # starting `<svg` tag.
      @test startswith(rendered, r"(<(\?|!)[^>]+>\n?)*<svg")
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
      options = Dict{String, String}("theme" => "materia")
      diagram = Diagram(:plantuml, "A -> B: C"; options)

      # The most straightforward way to differentiate between the themes used
      # for testing is by checking the associated fonts. The "Materia" theme
      # relies on "Verdana", whereas the "Sketchy" theme relies on the
      # handwritten look of "Segoe Print"
      @testset "defaults to `Diagram` options" begin
        rendered = String(render(diagram, "svg"))

        @test occursin("Verdana", rendered)
      end

      @testset "allows definition at render-time" begin
        rendered = String(
          render(diagram, "svg"; options = Dict{String, String}("theme" => "sketchy")),
        )

        @test occursin("Segoe Print", rendered)
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
    @test_throws(InvalidOutputFormatError, show(IOBuffer(), PDF_MIME_TYPE, svgbob_diagram))
    @test !showable(PDF_MIME_TYPE, svgbob_diagram)
    @test_throws(InvalidOutputFormatError, sprint(show, PNG_MIME_TYPE, svgbob_diagram))
    @test !showable(PNG_MIME_TYPE, svgbob_diagram)
    @test_throws(
      InvalidOutputFormatError,
      show(IOBuffer(), MIME"image/jpeg"(), svgbob_diagram)
    )
    @test !showable("image/jpeg", svgbob_diagram)
    testShowMethodRenders(svgbob_diagram, SVG_MIME_TYPE, "svg")
    @test !showable("non-existent/mime-type", svgbob_diagram)

    plantuml_diagram = Diagram(:PlantUML, "A -> B: C")
    testShowMethodRenders(plantuml_diagram, PNG_MIME_TYPE, "png")
    # PlantUML diagrams support SVG, but are not part of the
    # `LIMITED_DIAGRAM_SUPPORT` as they support more output formats.
    #
    # Given that `show` is tested directly, through `testShowMethodRenders`, it
    # is necessary to make sure a `showable` method is available to indicate
    # SVG is always supported to those enviroments that need to query that
    # information
    @test showable(SVG_MIME_TYPE, plantuml_diagram)
    testShowMethodRenders(plantuml_diagram, SVG_MIME_TYPE, "svg")

    @testset "`text/plain`" begin
      plain_text_mime_type = MIME"text/plain"()

      @testset "without ASCII/Unicode rendering support" begin
        # These diagram types should simply display their `specification`
        @test sprint(show, plain_text_mime_type, svgbob_diagram) ==
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

        Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = plain_text_mime_type
        testShowMethodRenders(plantuml_diagram, MIME"text/plain"(), "txt")

        @testset "generates an error if an invalid `text/plain` MIME type is configured" begin
          Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = PNG_MIME_TYPE

          @test_throws(
            UnsupportedMIMETypeError,
            show(IOBuffer(), plain_text_mime_type, plantuml_diagram)
          )
        end

        Kroki.TEXT_PLAIN_SHOW_MIME_TYPE[] = original_text_plain_mimetype
      end
    end

    @testset "overrides" begin
      diagram = Diagram(:plantuml, "A -> B: C")

      @testset "for `image/svg+xml`" begin
        # SVG is supported by default
        @test showable(SVG_MIME_TYPE, diagram)
        overrideShowable(SVG_MIME_TYPE, :plantuml, false)
        @test !showable(SVG_MIME_TYPE, diagram)
      end

      @testset "for other MIME types" begin
        # PDF is supported explicitly for PlantUML through the
        # `LIMITED_DIAGRAM_SUPPORT`
        @test showable(PDF_MIME_TYPE, diagram)
        overrideShowable(PDF_MIME_TYPE, :plantuml, false)
        @test !showable(PDF_MIME_TYPE, diagram)
      end

      resetShowableOverrides()
      @test showable(SVG_MIME_TYPE, diagram)
      @test showable(PDF_MIME_TYPE, diagram)

      @testset "diagram types are case insensitive" begin
        overrideShowable(SVG_MIME_TYPE, :PlAnTuMl, false)
        @test !showable(SVG_MIME_TYPE, diagram)

        overrideShowable(PDF_MIME_TYPE, :PlantUML, false)
        @test !showable(PDF_MIME_TYPE, diagram)
      end

      resetShowableOverrides()
      @test showable(SVG_MIME_TYPE, diagram)
      @test showable(PDF_MIME_TYPE, diagram)
    end
  end
end

end
