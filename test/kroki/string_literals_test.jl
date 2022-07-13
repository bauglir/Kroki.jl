module StringLiteralsTest

using Test: @test, @testset

using Kroki: Diagram, @mermaid_str, @plantuml_str

@testset "diagram string literals" begin
  # String literal macros should be defined as a convenient way for
  # specifying diagrams.
  #
  # This is not an exhaustive test as these are dynamically generated. The
  # basic functionality is only verified for key diagram types
  string_literal_plantuml = plantuml"A -> B: C"
  diagram_type_plantuml = Diagram(:PlantUML, "A -> B: C")
  # The leading newlines make sure the alignment of the plain text
  # representations is identical across both calling methods
  @test "\n$string_literal_plantuml" == "\n$diagram_type_plantuml"

  string_literal_mermaid = mermaid"graph TD; A --> B"
  diagram_type_mermaid = Diagram(:mermaid, "graph TD; A --> B")
  @test "$string_literal_mermaid" == "$diagram_type_mermaid"

  @testset "support interpolation" begin
    # String macros do no support string interpolation out-of-the-box, this
    # needs to be manually implemented, so needs dedicated testing
    message = "Z"
    diagram = plantuml"X -> Y: $(message ^ 5)"
    @test occursin(message^5, diagram.specification)
  end
end

end
