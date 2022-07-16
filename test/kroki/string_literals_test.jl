module StringLiteralsTest

using Test: @test, @testset

using Kroki: Diagram, @mermaid_str, @plantuml_str

@testset "diagram string literals" begin
  # String literal macros should be defined as a convenient way for
  # specifying diagrams.
  #
  # This is not an exhaustive test as these are dynamically generated. The
  # basic functionality is only verified for key diagram types.
  #
  # Note that the `specification`s and `type`s are compared directly. Comparing
  # the resulting `Diagram`s directly compares their rendered versions which is
  # a bit more finicky and duplicating test logic for `Base.show`
  @testset "are equivalent to using `Diagram` constructors" begin
    @testset "PlantUML" begin
      string_literal = plantuml"A -> B: C"
      diagram_constructor = Diagram(:plantuml, "A -> B: C")

      @test string_literal.specification === diagram_constructor.specification
      @test string_literal.type === diagram_constructor.type
    end

    @testset "Mermaid" begin
      string_literal = mermaid"graph TD; A --> B"
      diagram_constructor = Diagram(:mermaid, "graph TD; A --> B")

      @test string_literal.specification === diagram_constructor.specification
      @test string_literal.type === diagram_constructor.type
    end
  end

  @testset "support interpolation" begin
    # String macros do no support string interpolation out-of-the-box, this
    # needs to be manually implemented, so needs dedicated testing
    message = "Z"
    diagram = plantuml"X -> Y: $(message ^ 5)"
    @test occursin(message^5, diagram.specification)
  end
end

end
