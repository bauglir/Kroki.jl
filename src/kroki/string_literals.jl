module StringLiterals

using ..Kroki: Diagram, LIMITED_DIAGRAM_SUPPORT

# Helper function implementing string interpolation to be used in conjunction
# with macros defining diagram specification string literals, as they do not
# support string interpolation by default.
#
# Returns an array of elements, e.g. `Expr`essions, `Symbol`s, `String`s that
# can be incorporated in the `args` of another `Expr`essions
function interpolate(specification::AbstractString)
  # Based on the interpolation code from the Markdown stdlib and
  # https://riptutorial.com/julia-lang/example/22952/implementing-interpolation-in-a-string-macro
  components = Any[]

  # Turn the string is into an `IOBuffer` to make it more straightforward to
  # parse it in an incremental fashion
  stream = IOBuffer(specification)

  while !eof(stream)
    # The `$` is omitted from the result by `readuntil` by default, no need for
    # further processing
    push!(components, readuntil(stream, '$'))

    if !eof(stream)
      # If an interpolation indicator was found, try to parse the smallest
      # expression to interpolate and then keep parsing the stream for further
      # interpolations
      started_at = position(stream)
      expr, parsed_count = Meta.parse(read(stream, String), 1; greedy = false)
      seek(stream, started_at + parsed_count - 1)
      push!(components, expr)
    end
  end

  esc.(components)
end

# Links to the main documentation for each diagram type for inclusion in the
# string literal docstrings
DIAGRAM_DOCUMENTATION_URLS = Dict{Symbol, String}(
  :actdiag => "http://blockdiag.com/en/actdiag",
  :blockdiag => "http://blockdiag.com/en/blockdiag",
  :bpmn => "https://www.omg.org/spec/BPMN",
  :bytefield => "https://bytefield-svg.deepsymmetry.org",
  :c4plantuml => "https://github.com/plantuml-stdlib/C4-PlantUML",
  :diagramsnet => "https://diagrams.net",
  :ditaa => "http://ditaa.sourceforge.net",
  :erd => "https://github.com/BurntSushi/erd",
  :excalidraw => "https://excalidraw.com",
  :graphviz => "https://graphviz.org",
  :mermaid => "https://mermaid-js.github.io",
  :nomnoml => "https://www.nomnoml.com",
  :nwdiag => "http://blockdiag.com/en/nwdiag",
  :packetdiag => "http://blockdiag.com/en/nwdiag",
  :pikchr => "https://pikchr.org",
  :plantuml => "https://plantuml.com",
  :rackdiag => "http://blockdiag.com/en/nwdiag",
  :seqdiag => "http://blockdiag.com/en/seqdiag",
  :structurizr => "https://structurizr.com",
  :svgbob => "https://ivanceras.github.io/content/Svgbob.html",
  :umlet => "https://github.com/umlet/umlet",
  :vega => "https://vega.github.io/vega",
  :vegalite => "https://vega.github.io/vega-lite",
  :wavedrom => "https://wavedrom.com",
)

# The union of the values of `LIMITED_DIAGRAM_SUPPORT` corresponds to all
# supported `Diagram` types. The `values` call returns an array of arrays that
# may contain duplicate diagram types due to some types supporting rendering to
# multiple MIME types
for diagram_type in unique(Iterators.flatten(values(LIMITED_DIAGRAM_SUPPORT)))
  macro_name = Symbol("$(diagram_type)_str")
  macro_signature = Symbol("@$macro_name")
  # To be able to interpolate the `diagram_type` into the macro's body it needs
  # to be quoted twice, so that it does not get interpreted as the name of a
  # variable. First for `@eval`, then for the macro itself
  macro_diagram_type = QuoteNode(QuoteNode(diagram_type))

  diagram_url = get(DIAGRAM_DOCUMENTATION_URLS, diagram_type, "https://kroki.io/#support")

  docstring = "String literal for instantiating [`$diagram_type`]($diagram_url) [`Diagram`](@ref)s."

  @eval begin
    export $macro_signature

    @doc $docstring macro $macro_name(specification::AbstractString)
      Expr(
        :call,
        :Diagram,
        $macro_diagram_type,
        Expr(:call, string, interpolate(specification)...),
      )
    end
  end
end

end