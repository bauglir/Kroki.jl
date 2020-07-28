# Kroki.jl

```@meta
CurrentModule = Kroki
```

*Diagram from textual description generator for Julia*.

A package integrating Julia with [Kroki](https://kroki.io), a service for
generating *diagrams* from *textual* descriptions.

```@setup introduction
using Kroki
introduction_visual = plantuml"""
Kroki -> Julia: I'm here to help.
Julia -> Kroki: With what?
Kroki -> Julia: Rendering diagrams!
"""
```
```@example introduction
introduction_visual #hide
```

Kroki provides support for a wide array of diagramming languages such as
[Ditaa](http://ditaa.sourceforge.net/), [Graphviz](https://www.graphviz.org/),
[Mermaid](https://mermaidjs.github.io/), [PlantUML](https://plantuml.com) and
[many more](https://kroki.io/#support). The package can be configured to use
the publicly hosted server at [https://kroki.io](https://kroki.io) or
[self-hosted instances](https://docs.kroki.io/kroki/setup/install/) (see
[`render`](@ref) for configuration instructions). A basic configuration file
(`docker-services.yml`) for [Docker Compose](https://docs.docker.com/compose/)
is available in the `support` folder of the package for those interested in
self-hosting the service.

The aim of the package is to make it easy to integrate descriptive diagrams
within code and docstrings (rendered as text), while upgrading the diagrams to
good looking visuals whenever possible, e.g. in the context of
[Documenter](https://juliadocs.github.io/Documenter.jl/stable/) or
[Jupyter](https://jupyter.org)/[IJulia](https://github.com/JuliaLang/IJulia.jl),
using SVG or other output formats.

## Contents

```@contents
Pages = [ "api.md" ]
```
