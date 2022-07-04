# Kroki.jl

Enables a wide array of textual diagramming tools, such as
[Graphviz](https://www.graphviz.org), [Mermaid](https://mermaidjs.github.io),
[PlantUML](https://plantuml.com),
[svgbob](https://ivanceras.github.io/content/Svgbob.html) and [many
more](https://kroki.io/#support) within Julia through the
[Kroki](https://kroki.io) service.

![Kroki REPL Demo](./kroki-demo-repl.gif)

The aim of the package is to make it straightforward to store descriptive
diagrams close to, or even within, code. Additionally, it supports progressive
enhancement of these diagrams in environments, e.g.
[Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/),
[Pluto.jl](https://github.com/fonsp/Pluto.jl), or
[Jupyter](https://jupyter.org), that support richer media types such as SVG or
JPEG.

![Kroki Pluto Demo](./kroki-demo-pluto.gif)

See the [poster](https://live.juliacon.org/uploads/posters/M8KTBL.pdf)
presented at [JuliaCon 2020's poster
session](https://pretalx.com/juliacon2020/talk/9BNNMD/) for more information
and background.

## Installation & Usage

Install Kroki through Julia's package manager

```
(v1.7) pkg> add Kroki
```

Construct diagrams using the
[`Diagram`](https://bauglir.github.io/Kroki.jl/stable/api/#Kroki.Diagram) type
or any of the available [string
literals](https://bauglir.github.io/Kroki.jl/stable/api/#String-Literals). Then
either rely on the available `Base.show` overloads, or call the
[`render`](https://bauglir.github.io/Kroki.jl/stable/api/#Kroki.render)
function with a specific output format, to visualize them.

```@setup introduction
using Kroki
```

```@example introduction
plantuml"""
Kroki -> Julia: Hello!
Julia -> Kroki: Hi!
Kroki -> Julia: Can I draw some diagrams for you?
Julia -> Kroki: Sure!
"""
```

See the [examples section](@ref Examples) for more details and, well, examples.

The package can be configured to use the publicly hosted server at
[https://kroki.io](https://kroki.io) or a [self-hosted
instance](https://docs.kroki.io/kroki/setup/install), see [`setEndpoint!`](@ref
Kroki.Service.setEndpoint!) for details. Facilities, e.g. [`start!`](@ref
Kroki.Service.start!), [`status`](@ref Kroki.Service.status), [`stop!`](@ref
Kroki.Service.stop!), etc. are included to help with the self-hosting scenario,
provided [Docker Compose](https://docs.docker.com/compose) is available.

## Contents

```@contents
Pages = [ "api.md" ]
```
