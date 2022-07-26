module KrokiTest

using Test: @test, @testset

using Kroki: MIMEToDiagramTypeMap, getDiagramTypeMetadata, renderDiagramSupportAsMarkdown

@testset "Kroki" begin
  @testset "`renderDiagramSupportAsMarkdown`" begin
    @testset "includes defined support and `image/svg+xml`" begin
      plantuml_metadata = getDiagramTypeMetadata(:plantuml)
      svgbob_metadata = getDiagramTypeMetadata(:svgbob)

      # Strip newlines that are introduced by writing the string markers on
      # their own lines
      expected_markdown_table = chomp("""
      | | `A` | `B` | `image/svg+xml` |
      | --: | :-: | :-: | :-: |
      | [$(plantuml_metadata.name)]($(plantuml_metadata.url)) |  | ✅ | ✅ |
      | [$(svgbob_metadata.name)]($(svgbob_metadata.url)) | ✅ |  | ✅ |
      """)

      support_definition =
        MIMEToDiagramTypeMap(MIME"B"() => (:plantuml,), MIME"A"() => (:svgbob,))

      @test renderDiagramSupportAsMarkdown(support_definition) == expected_markdown_table
    end

    @testset "does not include `image/svg+xml` again if included" begin
      vegalite_metadata = getDiagramTypeMetadata(:vegalite)

      expected_markdown_table = chomp("""
      | | `image/svg+xml` |
      | --: | :-: |
      | [$(vegalite_metadata.name)]($(vegalite_metadata.url)) | ✅ |
      """)

      support_definition = MIMEToDiagramTypeMap(MIME"image/svg+xml"() => (:vegalite,))

      @test renderDiagramSupportAsMarkdown(support_definition) == expected_markdown_table
    end
  end

  # Include the test suites for all submodules
  include.(readdir(joinpath(@__DIR__, "kroki"); join = true))
end

end
