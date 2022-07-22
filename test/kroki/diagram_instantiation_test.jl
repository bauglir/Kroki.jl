module DiagramInstantiationTest

using Test: @test, @testset

using Kroki: Diagram

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
      diagram_path = joinpath(@__DIR__, "..", "assets", "plantuml-example.puml")
      expected_specification = read(diagram_path, String)

      diagram = Diagram(:plantuml; path = diagram_path)

      @test diagram.specification === expected_specification
    end

    @testset "optionally accepts `options`" begin
      expected_options = Dict("key" => "value")

      diagram = Diagram(:plantuml; options = expected_options, specification = "A -> B: C")

      @test diagram.options === expected_options
    end

    @testset "providing the `specification` keyword argument stores it" begin
      expected_specification = "A -> B: C"

      diagram = Diagram(:plantuml; specification = expected_specification)

      @test diagram.specification === expected_specification
    end
  end
end

end
