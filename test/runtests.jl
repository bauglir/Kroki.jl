module KrokiTest

using Test: @test, @testset

using Kroki: MIMEToDiagramTypeMap, renderDiagramSupportAsMarkdown

@testset "Kroki" begin
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
