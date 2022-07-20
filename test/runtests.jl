module KrokiTest

using Test: @testset, @test

using Kroki: Diagram, MIMEToDiagramTypeMap, renderDiagramSupportAsMarkdown

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

  @testset "`renderDiagramSupportAsMarkdown`" begin
    @testset "includes defined support and `image/svg+xml`" begin
      # Strip newlines that are introduced by writing the string markers on
      # their own lines
      expected_markdown_table = chomp("""
      | | `A` | `B` | `image/svg+xml` |
      | --: | :-: | :-: | :-: |
      | bar |  | ✅ | ✅ |
      | foo | ✅ |  | ✅ |
      """)

      support_definition = MIMEToDiagramTypeMap(MIME"B"() => (:bar,), MIME"A"() => (:foo,))

      @test renderDiagramSupportAsMarkdown(support_definition) == expected_markdown_table
    end

    @testset "does not include `image/svg+xml` again if included" begin
      expected_markdown_table = chomp("""
      | | `image/svg+xml` |
      | --: | :-: |
      | foo | ✅ |
      """)

      support_definition = MIMEToDiagramTypeMap(MIME"image/svg+xml"() => (:foo,))

      @test renderDiagramSupportAsMarkdown(support_definition) == expected_markdown_table
    end
  end

  # Include the test suites for all submodules
  include.(readdir(joinpath(@__DIR__, "kroki"); join = true))
end

end
