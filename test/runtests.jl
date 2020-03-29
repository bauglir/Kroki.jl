module KrokiTest

using Test: @testset, @test, @test_nowarn, @test_throws

using Kroki: Diagram

@testset "Kroki" begin
  @testset "`Diagram`" begin
    @testset "requires `Symbol` parameter" begin
      @test_nowarn Diagram{Val{:Foo}}("")
      @test_throws(AssertionError, Diagram{Val{1}}(""))
    end

    @testset "shorthand automatically parameterizes type" begin
      content = "A -> B: C"
      type = :PlantUML

      @test Diagram(type, content) === Diagram{Val{type}}(content)
    end
  end
end

end
