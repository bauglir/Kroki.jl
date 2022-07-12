var documenterSearchIndex = {"docs":
[{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"CurrentModule = Kroki","category":"page"},{"location":"api/#Public","page":"API","title":"Public","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Kroki\nDiagram\nrender","category":"page"},{"location":"api/#Kroki.Kroki","page":"API","title":"Kroki.Kroki","text":"The main Module containing the necessary types of functions for integration with a Kroki service.\n\nDefines Base.show and corresponding Base.showable methods for different output formats and Diagram types, so they render in their most optimal form in different environments (e.g. the documentation system, Documenter output, Pluto, Jupyter, etc.).\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Diagram","page":"API","title":"Kroki.Diagram","text":"struct Diagram\n\nA representation of a diagram that can be rendered by a Kroki service.\n\nConstructors\n\nDiagram(type::Symbol, specification::AbstractString)\n\nConstructs a Diagram from the specification for a specific type of diagram.\n\nDiagram(type::Symbol; path::AbstractString, specification::AbstractString)\n\nConstructs a Diagram from the specification for a specific type of diagram, or loads the specification from the provided path.\n\nSpecifying both, or neither, keyword arguments is invalid.\n\nExamples\n\njulia> Kroki.Diagram(:PlantUML, \"Kroki -> Julia: Hello Julia!\")\n     ┌─────┐          ┌─────┐\n     │Kroki│          │Julia│\n     └──┬──┘          └──┬──┘\n        │ Hello Julia!   │\n        │───────────────>│\n     ┌──┴──┐          ┌──┴──┐\n     │Kroki│          │Julia│\n     └─────┘          └─────┘\n\nFields\n\nspecification::AbstractString\nThe textual specification of the diagram.\ntype::Symbol\nThe type of diagram specification (e.g. ditaa, Mermaid, PlantUML, etc.). This value is case-insensitive.\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.render","page":"API","title":"Kroki.render","text":"render(diagram::Diagram, output_format::AbstractString) -> Vector{UInt8}\n\n\nRenders a Diagram through a Kroki service to the specified output format.\n\nIf the Kroki service responds with an error, throws an InvalidDiagramSpecificationError or InvalidOutputFormatError if a know type of error occurs. Other errors (e.g. HTTP.ExceptionRequest.StatusError for connection errors) are propagated if they occur.\n\nSVG output is supported for all Diagram types. See Kroki's website for an overview of other supported output formats per diagram type. Note that this list may not be entirely up-to-date.\n\n\n\n\n\n","category":"function"},{"location":"api/#Service-Management","page":"API","title":"Service Management","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ Kroki.Service ]\nOrder = [ :module, :type, :function ]\nFilter = name -> \"$name\" !== \"executeDockerCompose\"","category":"page"},{"location":"api/#Kroki.Service","page":"API","title":"Kroki.Service","text":"Defines functions and constants managing the Kroki service the rest of the package uses to render diagrams. These services can be either local or remote.\n\nThis module also enables management of a local service instance, provided Docker and Docker Compose are available on the system.\n\nExports\n\nImports\n\nBase\nCore\nDocStringExtensions\nKroki.Documentation\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Service.DockerComposeExecutionError","page":"API","title":"Kroki.Service.DockerComposeExecutionError","text":"struct DockerComposeExecutionError <: Exception\n\nA specialized Exception to include reporting instructions for specific types of errors that may occur while trying to execute docker-compose.\n\nFields\n\nmessage::String\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.Service.setEndpoint!","page":"API","title":"Kroki.Service.setEndpoint!","text":"setEndpoint!() -> String\nsetEndpoint!(endpoint::AbstractString) -> String\n\n\nSets the ENDPOINT using a fallback mechanism if no endpoint is provided.\n\nThe fallback mechanism checks for a KROKI_ENDPOINT environment variable specifying an endpoint (e.g. to be used across Julia instances). If this environment variable is also not present the DEFAULT_ENDPOINT is used.\n\nThis can, for instance, be used in cases where a privately hosted instance is available or when a local service has been start!ed.\n\nReturns the value that ENDPOINT got set to.\n\nExamples\n\nsetEndpoint!()\nsetEndpoint!(\"http://localhost:8000\")\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.start!","page":"API","title":"Kroki.Service.start!","text":"start!()\nstart!(update_endpoint::Bool)\n\n\nStarts the Kroki service components on the local system, optionally, ensuring ENDPOINT points to them.\n\nPass false to the function to prevent the ENDPOINT from being updated. The default behavior is to update.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.status-Tuple{}","page":"API","title":"Kroki.Service.status","text":"status() -> Any\n\n\nReturns a NamedTuple where the keys are the names of the service components and the values their corresponding 'running' state.\n\nExamples\n\njulia> status()\n(core = true, mermaid = false)\n\n\n\n\n\n","category":"method"},{"location":"api/#Kroki.Service.stop!","page":"API","title":"Kroki.Service.stop!","text":"stop!()\nstop!(perform_cleanup::Bool)\n\n\nStops any running Kroki service components ensuring ENDPOINT no longer points to the stopped service.\n\nCleans up left-over containers by default. This behavior can be turned off by passing false to the function.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.update!-Tuple{}","page":"API","title":"Kroki.Service.update!","text":"update!()\n\n\nUpdates the Docker images for the individual Kroki service components.\n\n\n\n\n\n","category":"method"},{"location":"api/#api-string-literals","page":"API","title":"String Literals","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ Kroki ]\nOrder = [ :macro ]\nFilter = m -> endswith(\"$m\", \"_str\")","category":"page"},{"location":"api/#Kroki.@actdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@actdiag_str","text":"String literal for instantiating actdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@blockdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@blockdiag_str","text":"String literal for instantiating blockdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@bpmn_str-Tuple{AbstractString}","page":"API","title":"Kroki.@bpmn_str","text":"String literal for instantiating bpmn Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@bytefield_str-Tuple{AbstractString}","page":"API","title":"Kroki.@bytefield_str","text":"String literal for instantiating bytefield Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@c4plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@c4plantuml_str","text":"String literal for instantiating c4plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@ditaa_str-Tuple{AbstractString}","page":"API","title":"Kroki.@ditaa_str","text":"String literal for instantiating ditaa Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@erd_str-Tuple{AbstractString}","page":"API","title":"Kroki.@erd_str","text":"String literal for instantiating erd Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@excalidraw_str-Tuple{AbstractString}","page":"API","title":"Kroki.@excalidraw_str","text":"String literal for instantiating excalidraw Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@graphviz_str-Tuple{AbstractString}","page":"API","title":"Kroki.@graphviz_str","text":"String literal for instantiating graphviz Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@mermaid_str-Tuple{AbstractString}","page":"API","title":"Kroki.@mermaid_str","text":"String literal for instantiating mermaid Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nomnoml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nomnoml_str","text":"String literal for instantiating nomnoml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nwdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nwdiag_str","text":"String literal for instantiating nwdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@packetdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@packetdiag_str","text":"String literal for instantiating packetdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@pikchr_str-Tuple{AbstractString}","page":"API","title":"Kroki.@pikchr_str","text":"String literal for instantiating pikchr Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@plantuml_str","text":"String literal for instantiating plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@rackdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@rackdiag_str","text":"String literal for instantiating rackdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@seqdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@seqdiag_str","text":"String literal for instantiating seqdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@structurizr_str-Tuple{AbstractString}","page":"API","title":"Kroki.@structurizr_str","text":"String literal for instantiating structurizr Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@svgbob_str-Tuple{AbstractString}","page":"API","title":"Kroki.@svgbob_str","text":"String literal for instantiating svgbob Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@umlet_str-Tuple{AbstractString}","page":"API","title":"Kroki.@umlet_str","text":"String literal for instantiating umlet Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vega_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vega_str","text":"String literal for instantiating vega Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vegalite_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vegalite_str","text":"String literal for instantiating vegalite Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@wavedrom_str-Tuple{AbstractString}","page":"API","title":"Kroki.@wavedrom_str","text":"String literal for instantiating wavedrom Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Private","page":"API","title":"Private","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"DiagramPathOrSpecificationError\nInvalidDiagramSpecificationError\nInvalidOutputFormatError\nLIMITED_DIAGRAM_SUPPORT\nUriSafeBase64Payload","category":"page"},{"location":"api/#Kroki.DiagramPathOrSpecificationError","page":"API","title":"Kroki.DiagramPathOrSpecificationError","text":"struct DiagramPathOrSpecificationError <: Exception\n\nAn Exception to be thrown when the path and specification keyword arguments to Diagram are not specified mutually exclusive.\n\nFields\n\npath::Union{Nothing, AbstractString}\nspecification::Union{Nothing, AbstractString}\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.InvalidDiagramSpecificationError","page":"API","title":"Kroki.InvalidDiagramSpecificationError","text":"struct InvalidDiagramSpecificationError <: Exception\n\nAn Exception to be thrown when a Diagram representing an invalid specification is passed to render.\n\nFields\n\nerror::String\ncause::Diagram\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.InvalidOutputFormatError","page":"API","title":"Kroki.InvalidOutputFormatError","text":"struct InvalidOutputFormatError <: Exception\n\nAn Exception to be thrown when a Diagram is rendered to an unsupported or invalid output format.\n\nFields\n\nerror::String\ncause::Diagram\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.LIMITED_DIAGRAM_SUPPORT","page":"API","title":"Kroki.LIMITED_DIAGRAM_SUPPORT","text":"Some MIME types are not supported by all diagram types, this constant contains all these limitations. The union of all values corresponds to all supported Diagram types.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.UriSafeBase64Payload","page":"API","title":"Kroki.UriSafeBase64Payload","text":"UriSafeBase64Payload(diagram::Diagram) -> String\n\n\nCompresses a Diagram's specification using zlib, turning the resulting bytes into a URL-safe Base64 encoded payload (i.e. replacing + by - and / by _) to be used in communication with a Kroki service.\n\nSee the Kroki documentation for more information.\n\n\n\n\n\n","category":"function"},{"location":"api/#Documentation","page":"API","title":"Documentation","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ Kroki.Documentation ]","category":"page"},{"location":"api/#Kroki.Documentation","page":"API","title":"Kroki.Documentation","text":"Contains templates and a helper macro @setupDocstringMarkup to easily set up consistent docstring formats across modules.\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Documentation.@setupDocstringMarkup-Tuple{}","page":"API","title":"Kroki.Documentation.@setupDocstringMarkup","text":"Helper macro ensuring consistent docstring markup across modules through templating.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Service-Management-2","page":"API","title":"Service Management","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ Kroki.Service ]\nOrder = [ :constant ]","category":"page"},{"location":"api/#Kroki.Service.DEFAULT_ENDPOINT","page":"API","title":"Kroki.Service.DEFAULT_ENDPOINT","text":"The default ENDPOINT to use, i.e. the publicly hosted version.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.Service.ENDPOINT","page":"API","title":"Kroki.Service.ENDPOINT","text":"The currently active Kroki service endpoint being used.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.Service.SERVICE_DEFINITION_FILE","page":"API","title":"Kroki.Service.SERVICE_DEFINITION_FILE","text":"Path to the Docker Compose definitions for running a local Kroki service.\n\n\n\n\n\n","category":"constant"},{"location":"api/","page":"API","title":"API","text":"Kroki.Service.executeDockerCompose","category":"page"},{"location":"api/#Kroki.Service.executeDockerCompose","page":"API","title":"Kroki.Service.executeDockerCompose","text":"executeDockerCompose(cmd::Vector{String}) -> String\n\n\nHelper function for executing Docker Compose commands.\n\nReturns captured stdout.\n\nThrows an ErrorException if Docker and/or Docker Compose aren't available. Throws a DockerComposeExecutionError if any other exception occurs during execution.\n\n\n\n\n\n","category":"function"},{"location":"examples/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"This page shows the different ways diagrams can be rendered. Most content for the examples is taken from Kroki's website, or the individual diagramming tools websites as linked from the docstring of various string literals.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using Kroki","category":"page"},{"location":"examples/#String-literals","page":"Examples","title":"String literals","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The most straightforward way to create diagrams is to rely on the string literals for each of the available diagram types. The package needs to be updated to add string literals whenever the Kroki service adds a new diagramming tool. In case a string literal is not available, it will be necessary to resort to using the Diagram type directly.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"ditaa\"\"\"\n      +--------+\n      |        |\n      | Julia  |\n      |        |\n      +--------+\n          ^\n  request |\n          v\n  +-------------+\n  |             |\n  |    Kroki    |\n  |             |---+\n  +-------------+   |\n       ^  ^         | inflate\n       |  |         |\n       v  +---------+\n  +-------------+\n  |             |\n  |    Ditaa    |\n  |             |----+\n  +-------------+    |\n             ^       | process\n             |       |\n             +-------+\n\"\"\"","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"blockdiag\"\"\"\nblockdiag {\n  Kroki -> generates -> \"Block diagrams\";\n  Kroki -> is -> \"very easy!\";\n\n  Kroki [color = \"greenyellow\"];\n  \"Block diagrams\" [color = \"pink\"];\n  \"very easy!\" [color = \"orange\"];\n}\n\"\"\"","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"svgbob\"\"\"\n        ▲\n    Uin ┊   .------------------------\n        ┊   |\n        ┊   |\n        *---'┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄▶\n\"\"\"","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"note: String Interpolation\nString interpolation for string literals is not readily supported by Julia, requiring custom logic by the package providing them. Kroki.jl's string literals support string interpolation. Please file an issue when encountering unexpected behavior.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"alice = \"Kroki\"\nbob = \"Julia\"\n\nplantuml\"\"\"\n$alice -> $bob: I'm here to help.\n$bob -> $alice: With what?\n$alice -> $bob: Rendering diagrams!\n\"\"\"","category":"page"},{"location":"examples/#examples-diagram-type","page":"Examples","title":"The Diagram type","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"String literals are effectively short-hands for instantiating a Diagram for a specific type of diagram. In certain cases, it may be more straightforward, or even necessary, to directly instantiate a Diagram. For instance, when a type of diagram is supported by the Kroki service but support for it has not been added to this package. In those cases, basic functionality like rendering to an SVG should typically still work in line with the following examples.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Diagram(:mermaid, \"\"\"\ngraph TD\n  A[ Anyone ] --> | Can help | B( Go to github.com/yuzutech/kroki )\n  B --> C{ How to contribute? }\n  C --> D[ Reporting bugs ]\n  C --> E[ Sharing ideas ]\n  C --> F[ Advocating ]\n\"\"\")","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"warning: Escaping special characters\nWhen the diagram description contains special characters, e.g. \\s, keep in mind that these need to be escaped for proper handling when instantiating a Diagram.Escaping is not typically necessary when using string literals.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Diagram(:svgbob, \"\"\"\n    0       3                          P *\n     *-------*      +y                    \\\\\n  1 /|    2 /|       ^                     \\\\\n   *-+-----* |       |                v0    \\\\       v3\n   | |4    | |7      | ◄╮               *----\\\\-----*\n   | *-----|-*     ⤹ +-----> +x        /      v X   \\\\\n   |/      |/       / ⤴               /        o     \\\\\n   *-------*       v                 /                \\\\\n  5       6      +z              v1 *------------------* v2\n\"\"\")","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"svgbob\"\"\"\n    0       3                          P *\n     *-------*      +y                    \\\n  1 /|    2 /|       ^                     \\\n   *-+-----* |       |                v0    \\       v3\n   | |4    | |7      | ◄╮               *----\\-----*\n   | *-----|-*     ⤹ +-----> +x        /      v X   \\\n   |/      |/       / ⤴               /        o     \\\n   *-------*       v                 /                \\\n  5       6      +z              v1 *------------------* v2\n\"\"\"","category":"page"},{"location":"examples/#Loading-from-a-file","page":"Examples","title":"Loading from a file","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Instead of directly specifying a diagram, Diagrams can also load the specifications from files. This is particularly useful when creating diagrams using other tooling, e.g. Structurizr or Excalidraw, or when sharing diagram definitions across documentation.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"To load a diagram from a file, specify the path of the file as the path keyword argument to Diagram.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Diagram(\n  :structurizr;\n  path = joinpath(@__DIR__, \"..\", \"architecture\", \"workspace.dsl\"),\n)","category":"page"},{"location":"examples/#Rendering-to-a-specific-format","page":"Examples","title":"Rendering to a specific format","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"To render to a specific format, explicitly call the render function on a Diagram, specifying the desired output format.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"warning: Output format support\nAll diagram types support SVG output, other supported output formats vary per diagram type. See Kroki's website for a, not entirely accurate, overview.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"mermaid_diagram = mermaid\"\"\"\ngraph LR\n  Foo --> Bar\n  Bar --> Baz\n  Bar --> Bar\n  Baz --> Quuz\n  Quuz --> Foo\n  Quuz --> Bar\n\"\"\"\n\nmermaid_diagram_as_png = render(mermaid_diagram, \"png\")\n\n# The PNG header\n# See http://www.libpng.org/pub/png/spec/1.2/PNG-Rationale.html#R.PNG-file-signature\nChar.(mermaid_diagram_as_png[1:8])","category":"page"},{"location":"examples/#Saving-to-a-file","page":"Examples","title":"Saving to a file","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Once a diagram has been rendered, it's straightforward to write it to a file using write.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"write(\"mermaid_diagram.png\", mermaid_diagram_as_png)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: Mermaid diagram as PNG example)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Note the difference in file size and fonts when rendering to SVG.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"write(\"mermaid_diagram.svg\", render(mermaid_diagram, \"svg\"))","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: Mermaid diagram as SVG example)","category":"page"},{"location":"#Kroki.jl","page":"Home","title":"Kroki.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Enables a wide array of textual diagramming tools, such as Graphviz, Mermaid, PlantUML, svgbob and many more within Julia through the Kroki service.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Kroki REPL Demo)","category":"page"},{"location":"","page":"Home","title":"Home","text":"The aim of the package is to make it straightforward to store descriptive diagrams close to, or even within, code. Additionally, it supports progressive enhancement of these diagrams in environments, e.g. Documenter.jl, Pluto.jl, or Jupyter, that support richer media types such as SVG or JPEG.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Kroki Pluto Demo)","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the poster presented at JuliaCon 2020's poster session for more information and background.","category":"page"},{"location":"#Installation-and-Usage","page":"Home","title":"Installation & Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Install Kroki through Julia's package manager","category":"page"},{"location":"","page":"Home","title":"Home","text":"(v1.7) pkg> add Kroki","category":"page"},{"location":"","page":"Home","title":"Home","text":"Construct diagrams using the Diagram type or any of the available string literals. Then either rely on the available Base.show overloads, or call the render function with a specific output format, to visualize them.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Kroki","category":"page"},{"location":"","page":"Home","title":"Home","text":"plantuml\"\"\"\nKroki -> Julia: Hello!\nJulia -> Kroki: Hi!\nKroki -> Julia: Can I draw some diagrams for you?\nJulia -> Kroki: Sure!\n\"\"\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the examples section for more details and, well, examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The package can be configured to use the publicly hosted server at https://kroki.io or a self-hosted instance, see setEndpoint! for details. Facilities, e.g. start!, status, stop!, etc. are included to help with the self-hosting scenario, provided Docker Compose is available.","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [ \"api.md\" ]","category":"page"}]
}
