module StringLiterals

using ..Kroki: Diagram, LIMITED_DIAGRAM_SUPPORT, getDiagramTypeMetadata

"""
Helper function implementing string interpolation to be used in conjunction
with macros defining diagram specification string literals, as they do not
support string interpolation by default.

Returns an array of elements, e.g. `Expr`essions, `Symbol`s, `String`s that can
be incorporated in the `args` of another `Expr`ession.
"""
function interpolate(specification::AbstractString)
  # Based on the interpolation code from the Markdown stdlib and
  # https://riptutorial.com/julia-lang/example/22952/implementing-interpolation-in-a-string-macro
  components = Any[]

  # Turn the string is into an `IOBuffer` to make it more straightforward to
  # parse it in an incremental fashion
  stream = IOBuffer(specification)

  while !eof(stream)
    # The `$` is omitted from the result by `readuntil` by default, it should
    # be reinstated later in case it turns out it was escaped
    push!(components, readuntil(stream, '$'))

    if !eof(stream)
      # The read above only checks for an interpolation sign in the stream. It
      # doesn't check whether that interpolation sign should actually trigger
      # interpolation, e.g. in case it was escaped
      if shouldInterpolate(stream)
        # If an interpolation indicator was found, try to parse the smallest
        # expression to interpolate
        started_at = position(stream)
        expr, parsed_count = Meta.parse(read(stream, String), 1; greedy = false)
        seek(stream, started_at + parsed_count - 1)
        push!(components, expr)
      else
        # In case the interpolation character was escaped, include it back in
        # the parsed result while removing its escape character
        components[end] = "$(components[end][1:end-1])\$"
      end
    end
  end

  esc.(components)
end

"""
When called at the start of an expression to interpolate, checks whether the
interpolation sign that triggered interpolation was escaped or not. This takes
into account multiple escaped escape characters in front of an interpolation
sign.
"""
function shouldInterpolate(stream::IO)
  interpolation_start = position(stream)

  # Move back to the first potential escape character, the `stream` should be
  # just after the `$`, and keep moving backwards in the stream counting the
  # number of escape characters. Interpolation should only happen if there's an
  # even number of escape characters
  skip(stream, -2)

  n_escape_characters = 0
  while peek(stream, Char) === '\\'
    n_escape_characters += 1
    skip(stream, -1)
  end

  seek(stream, interpolation_start)

  return iseven(n_escape_characters)
end

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

  diagram_type_metadata = getDiagramTypeMetadata(diagram_type)

  docstring = "String literal for instantiating [`$(diagram_type_metadata.name)`]($(diagram_type_metadata.url)) [`Diagram`](@ref)s."

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
