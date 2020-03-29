module Kroki

"""
A representation of a diagram that can be rendered by a Kroki service. The
specification of the diagram type, which is captured as a `Symbol` in the
type's parameter, is case-insensitive!

# Examples

```
Diagram{Val{:PlantUML}}("Kroki -> Julia: Hello Julia!")
```
"""
struct Diagram{Val}
  "The textual specification of the diagram"
  specification::AbstractString

  function Diagram{T}(specification::AbstractString) where T <: Val
    @assert T.parameters[1] isa Symbol
    new(specification)
  end
end

"""
Shorthand for constructing a [`Diagram`](@ref) without having to specify its
parametric part.
"""
Diagram(type::Symbol, specification::AbstractString) = Diagram{Val{type}}(specification)

end
