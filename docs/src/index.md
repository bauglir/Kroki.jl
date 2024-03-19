# Kroki.jl

Enables a wide array of textual diagramming tools, such as
[Graphviz](https://www.graphviz.org), [Mermaid](https://mermaidjs.github.io),
[PlantUML](https://plantuml.com),
[svgbob](https://ivanceras.github.io/content/Svgbob.html) and [many more](@ref
diagram-support) within Julia through the [Kroki](https://kroki.io) service.

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

Install the package through Julia's package manager

```
(v1.10) pkg> add Kroki
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

!!! warning "Getting Help"
    For feature requests and bug reports related to this Julia package use [the
    Issue tracker on GitHub](https://github.com/bauglir/Kroki.jl/issues).

    To get help regarding Kroki itself, e.g. for operational issues with the
    publicly hosted Kroki server, requests for adding support for additional
    diagram types, etc. please refer to [the Getting Help section of the Kroki
    documentation](https://docs.kroki.io/kroki/project/get-help/).

The package can be configured to use the publicly hosted server at
[https://kroki.io](https://kroki.io) or a [self-hosted
instance](https://docs.kroki.io/kroki/setup/install), see [`setEndpoint!`](@ref
Kroki.Service.setEndpoint!) for details. Facilities, e.g. [`start!`](@ref
Kroki.Service.start!), [`status`](@ref Kroki.Service.status), [`stop!`](@ref
Kroki.Service.stop!), etc. are included to help with the self-hosting scenario,
provided [Docker Compose](https://docs.docker.com/compose) is available.

!!! tip "Kroki and Continuous Integration (CI)"
    Running a dedicated Kroki instance in CI environments can help ensure more
    reliable builds, e.g. when building documentation with integrated diagrams,
    etc. There are multiple ways of achieving this, increasing in
    difficulty/maintenance burden.

    The service management functions mentioned above are the most
    straightforward way to get a local version of Kroki running. Public GitHub
    Actions runners have all the necessary tools supporting these functions
    readily installed. Hence, a call to [`Kroki.Service.start!`](@ref) is all
    that is necessary to run a local Kroki service on GitHub Actions. For
    instance from the `make.jl` script typically used for documentation
    generation. Other CI environments, such as GitLab CI, Travis, private
    GitHub Actions runners, etc. may require separate installation of Docker
    and/or Docker Compose.

    Alternatively, [the Docker Compose
    definitions](https://github.com/bauglir/Kroki.jl/blob/main/support/docker-services.yml)
    can be leveraged in combination with an action such as
    [`isbang/compose-action`](https://github.com/isbang/compose-action) to
    launch the necessary services.

    It is also possible to use functionality such as [service
    containers](https://docs.github.com/en/actions/using-containerized-services/about-service-containers).
    It is important to take into account such an approach will require
    duplication of much of the configuration readily provided by the solutions
    mentioned above. Refer to Kroki's documentation for more information on
    [the necessary container
    images](https://docs.kroki.io/kroki/setup/install/#images).

    In the last two cases it is important to remember to correctly configure
    the endpoint for the package using [`Kroki.Service.setEndpoint!`](@ref). In
    the first case this will be handled automatically, provided the services
    are started within the same Julia session as where the diagrams are
    rendered.

## [Supported Diagram Types](@id diagram-support)

The table below provides an overview of the different diagram types this
package supports, with links to their documentation, and the output formats
they can be rendered to.

```@eval
using Kroki, Markdown
Markdown.parse(Kroki.renderDiagramSupportAsMarkdown(Kroki.LIMITED_DIAGRAM_SUPPORT))
```

!!! note "Addressing errors in diagram type support"
    The information in this table should correspond to the one on [Kroki's
    website](https://kroki.io/#support), but is directly derived from the
    support as it is encoded in [this
    package](https://bauglir.github.io/Kroki.jl/stable/api/#Kroki.LIMITED_DIAGRAM_SUPPORT).

    Given that this information is a mirror of the information available on
    [Kroki's website](https://kroki.io/#support), it may not be entirely
    accurate with regards to actually supported output formats. Support for
    output formats needs to be addressed within the Kroki service and then
    mirrored into this package.

The [`Kroki.Service.info`](@ref) function can be used to obtain more detailed
information about the versions of the tools used to support the different
diagram types.

## Contents

```@contents
Pages = [ "api.md" ]
```
