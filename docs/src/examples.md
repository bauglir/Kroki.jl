# Examples

This page shows the different ways diagrams can be rendered. Most content for
the examples is taken from [Kroki's website](https://kroki.io), or the
individual diagramming tools websites as linked from the docstring of various
[string literals](@ref api-string-literals).

```@setup diagrams
using Kroki
```

## String literals

The most straightforward way to create diagrams is to rely on the [string
literals](@ref api-string-literals) for each of the available diagram types.
The package needs to be updated to add string literals whenever the [Kroki
service](https://kroki.io) adds a new diagramming tool. In case a string
literal is not available, it will be necessary to resort to using [the
`Diagram` type](@ref examples-diagram-type) directly.

```@example diagrams
ditaa"""
      +--------+
      |        |
      | Julia  |
      |        |
      +--------+
          ^
  request |
          v
  +-------------+
  |             |
  |    Kroki    |
  |             |---+
  +-------------+   |
       ^  ^         | inflate
       |  |         |
       v  +---------+
  +-------------+
  |             |
  |    Ditaa    |
  |             |----+
  +-------------+    |
             ^       | process
             |       |
             +-------+
"""
```

```@example diagrams
blockdiag"""
blockdiag {
  Kroki -> generates -> "Block diagrams";
  Kroki -> is -> "very easy!";

  Kroki [color = "greenyellow"];
  "Block diagrams" [color = "pink"];
  "very easy!" [color = "orange"];
}
"""
```

```@example diagrams
svgbob"""
        ▲
    Uin ┊   .------------------------
        ┊   |
        ┊   |
        *---'┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄▶
"""
```

!!! note "String Interpolation"

    String interpolation for string literals is not readily supported by Julia,
    requiring custom logic by the package providing them. Kroki.jl's string
    literals support string interpolation. Please [file an
    issue](https://github.com/bauglir/Kroki.jl/issues/new) when encountering
    unexpected behavior.

```@example diagrams
alice = "Kroki"
bob = "Julia"

plantuml"""
$alice -> $bob: I'm here to help.
$bob -> $alice: With what?
$alice -> $bob: Rendering diagrams!
"""
```

## [The `Diagram` type](@id examples-diagram-type)

String literals are effectively short-hands for instantiating a
[`Diagram`](@ref Kroki.Diagram) for a specific type of diagram. In certain
cases, it may be more straightforward, or even necessary, to directly
instantiate a [`Diagram`](@ref Kroki.Diagram). For instance, when a type of
diagram is supported by the Kroki service but support for it has not been added
to this package. In those cases, basic functionality like rendering to an SVG
should typically still work in line with the following examples.

```@example diagrams
Diagram(:mermaid, """
graph TD
  A[ Anyone ] --> | Can help | B( Go to github.com/yuzutech/kroki )
  B --> C{ How to contribute? }
  C --> D[ Reporting bugs ]
  C --> E[ Sharing ideas ]
  C --> F[ Advocating ]
""")
```

!!! warning "Escaping special characters"

    When the diagram description contains special characters, e.g. `\`s, keep
    in mind that these need to be escaped for proper handling when
    instantiating a [`Diagram`](@ref Kroki.Diagram).

    Escaping is not typically necessary when using [string literals](@ref
    api-string-literals).

```@example diagrams
Diagram(:svgbob, """
    0       3                          P *
     *-------*      +y                    \\
  1 /|    2 /|       ^                     \\
   *-+-----* |       |                v0    \\       v3
   | |4    | |7      | ◄╮               *----\\-----*
   | *-----|-*     ⤹ +-----> +x        /      v X   \\
   |/      |/       / ⤴               /        o     \\
   *-------*       v                 /                \\
  5       6      +z              v1 *------------------* v2
""")
```

```@example diagrams
svgbob"""
    0       3                          P *
     *-------*      +y                    \
  1 /|    2 /|       ^                     \
   *-+-----* |       |                v0    \       v3
   | |4    | |7      | ◄╮               *----\-----*
   | *-----|-*     ⤹ +-----> +x        /      v X   \
   |/      |/       / ⤴               /        o     \
   *-------*       v                 /                \
  5       6      +z              v1 *------------------* v2
"""
```

### Loading from a file

Instead of directly specifying a diagram, [`Diagram`](@ref)s can also load the
specifications from files. This is particularly useful when creating diagrams
using other tooling, e.g. [Structurizr](https://structurizr.com) or
[Excalidraw](https://excalidraw.com), or when sharing diagram definitions
across documentation.

To load a diagram from a file, specify the path of the file as the `path`
keyword argument to [`Diagram`](@ref).

```@example diagrams
Diagram(
  :structurizr;
  path = joinpath(@__DIR__, "..", "architecture", "workspace.dsl"),
)
```

## Rendering to a specific format

To render to a specific format, explicitly call the [`render`](@ref) function
on a [`Diagram`](@ref), specifying the desired output format.

!!! warning "Output format support"

    All diagram types support SVG output, other supported output formats vary
    per diagram type. See [Kroki's website](https://kroki.io/#support) for a,
    not entirely accurate, overview.

```@example diagrams
mermaid_diagram = mermaid"""
graph LR
  Foo --> Bar
  Bar --> Baz
  Bar --> Bar
  Baz --> Quuz
  Quuz --> Foo
  Quuz --> Bar
"""

mermaid_diagram_as_png = render(mermaid_diagram, "png")

# The PNG header
# See http://www.libpng.org/pub/png/spec/1.2/PNG-Rationale.html#R.PNG-file-signature
Char.(mermaid_diagram_as_png[1:8])
```

### Saving to a file

Once a diagram has been rendered, it's straightforward to write it to a file
using `write`.

```@example diagrams
write("mermaid_diagram.png", mermaid_diagram_as_png)
```

![Mermaid diagram as PNG example](mermaid_diagram.png)

Note the difference in file size and fonts when rendering to SVG.

```@example diagrams
write("mermaid_diagram.svg", render(mermaid_diagram, "svg"))
```

![Mermaid diagram as SVG example](mermaid_diagram.svg)
