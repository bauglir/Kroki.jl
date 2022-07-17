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

    # Note that escape sequences work differently when passed to string
    # literals as they would when passed to `Diagram` constructors. Within a
    # string literal the escape sequences can be written as they would be
    # interpreted by Kroki, i.e. `\\` means rendering a single backslash _to
    # Kroki_. When using the `Diagram` constructors it is necessary to add
    # additional escape sequences to accommodate for Julia's escape sequences,
    # i.e. to pass `\\` to Kroki it needs to be specified as `\\\\` to a
    # `Diagram` constructor
    @testset "escaping `\$` disables interpolation" begin
      diagram = plantuml"X -> Y: Z\$(not_interpolated_message)Z"
      @test diagram.specification === "X -> Y: Z\$(not_interpolated_message)Z"

      # Except if the escape character is itself escaped
      interpolated_message = "interpolated"
      diagram = plantuml"X -> Y: Z\\$(interpolated_message)Z"
      @test diagram.specification === "X -> Y: Z\\\\$(interpolated_message)Z"

      # This should extend to adding more escaped escape characters in front of
      # the interpolation
      diagram = plantuml"X -> Y: Z\\\$(not_interpolated_message)Z"
      @test diagram.specification === "X -> Y: Z\\\\\$(not_interpolated_message)Z"

      diagram = plantuml"X -> Y: Z\\\\$(interpolated_message)Z"
      @test diagram.specification === "X -> Y: Z\\\\\\\\$(interpolated_message)Z"
    end
  end
end

end
