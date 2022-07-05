var documenterSearchIndex = {"docs":
[{"location":"api/#API-1","page":"API","title":"API","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"CurrentModule = Kroki","category":"page"},{"location":"api/#Public-1","page":"API","title":"Public","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Kroki\nDiagram","category":"page"},{"location":"api/#Kroki.Kroki","page":"API","title":"Kroki.Kroki","text":"The main Module containing the necessary types of functions for integration with a Kroki service.\n\nDefines Base.show and corresponding Base.showable methods for different output formats and Diagram types, so they render in their most optimal form in different environments (e.g. the documentation system, Documenter output, Jupyter, etc.).\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Diagram","page":"API","title":"Kroki.Diagram","text":"struct Diagram\n\nA representation of a diagram that can be rendered by a Kroki service.\n\nExamples\n\njulia> Kroki.Diagram(:PlantUML, \"Kroki -> Julia: Hello Julia!\")\n     ┌─────┐          ┌─────┐\n     │Kroki│          │Julia│\n     └──┬──┘          └──┬──┘\n        │ Hello Julia!   │\n        │───────────────>│\n     ┌──┴──┐          ┌──┴──┐\n     │Kroki│          │Julia│\n     └─────┘          └─────┘\n\nFields\n\nspecification::AbstractString\nThe textual specification of the diagram\ntype::Symbol\nThe type of diagram specification (e.g. ditaa, Mermaid, PlantUML, etc.). This value is case-insensitive.\n\n\n\n\n\n","category":"type"},{"location":"api/#Service-Management-1","page":"API","title":"Service Management","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [ Kroki.Service ]\nOrder = [ :module, :type, :function ]\nFilter = name -> \"$name\" !== \"executeDockerCompose\"","category":"page"},{"location":"api/#Kroki.Service","page":"API","title":"Kroki.Service","text":"Defines functions and constants managing the Kroki service the rest of the package uses to render diagrams. These services can be either local or remote.\n\nThis module also enables management of a local service instance, provided Docker and Docker Compose are available on the system.\n\nExports\n\nImports\n\nBase\nCore\nDocStringExtensions\nKroki.Documentation\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Service.DockerComposeExecutionError","page":"API","title":"Kroki.Service.DockerComposeExecutionError","text":"struct DockerComposeExecutionError <: Exception\n\nA specialized Exception to include reporting instructions for specific types of errors that may occur while trying to execute docker-compose.\n\nFields\n\nmessage::String\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.Service.setEndpoint!","page":"API","title":"Kroki.Service.setEndpoint!","text":"setEndpoint!() -> String\nsetEndpoint!(endpoint::AbstractString) -> String\n\n\nSets the ENDPOINT using a fallback mechanism if no endpoint is provided.\n\nThe fallback mechanism checks for a KROKI_ENDPOINT environment variable specifying an endpoint (e.g. to be used across Julia instances). If this environment variable is also not present the DEFAULT_ENDPOINT is used.\n\nThis can, for instance, be used in cases where a privately hosted instance is available or when a local service has been start!ed.\n\nReturns the value that ENDPOINT got set to.\n\nExamples\n\nsetEndpoint!()\nsetEndpoint!(\"http://localhost:8000\")\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.start!","page":"API","title":"Kroki.Service.start!","text":"start!()\nstart!(update_endpoint::Bool)\n\n\nStarts the Kroki service components on the local system, optionally, ensuring ENDPOINT points to them.\n\nPass false to the function to prevent the ENDPOINT from being updated. The default behavior is to update.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.status-Tuple{}","page":"API","title":"Kroki.Service.status","text":"status() -> Any\n\n\nReturns a NamedTuple where the keys are the names of the service components and the values their corresponding 'running' state.\n\nExamples\n\njulia> status()\n(core = true, mermaid = false)\n\n\n\n\n\n","category":"method"},{"location":"api/#Kroki.Service.stop!","page":"API","title":"Kroki.Service.stop!","text":"stop!()\nstop!(perform_cleanup::Bool)\n\n\nStops any running Kroki service components ensuring ENDPOINT no longer points to the stopped service.\n\nCleans up left-over containers by default. This behavior can be turned off by passing false to the function.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.Service.update!-Tuple{}","page":"API","title":"Kroki.Service.update!","text":"update!()\n\n\nUpdates the Docker images for the individual Kroki service components.\n\n\n\n\n\n","category":"method"},{"location":"api/#Shorthands-1","page":"API","title":"Shorthands","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [ Kroki ]\nOrder = [ :macro ]\nFilter = m -> endswith(\"$m\", \"_str\")","category":"page"},{"location":"api/#Kroki.@actdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@actdiag_str","text":"Shorthand for instantiating actdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@blockdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@blockdiag_str","text":"Shorthand for instantiating blockdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@bpmn_str-Tuple{AbstractString}","page":"API","title":"Kroki.@bpmn_str","text":"Shorthand for instantiating bpmn Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@bytefield_str-Tuple{AbstractString}","page":"API","title":"Kroki.@bytefield_str","text":"Shorthand for instantiating bytefield Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@c4plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@c4plantuml_str","text":"Shorthand for instantiating c4plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@ditaa_str-Tuple{AbstractString}","page":"API","title":"Kroki.@ditaa_str","text":"Shorthand for instantiating ditaa Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@erd_str-Tuple{AbstractString}","page":"API","title":"Kroki.@erd_str","text":"Shorthand for instantiating erd Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@excalidraw_str-Tuple{AbstractString}","page":"API","title":"Kroki.@excalidraw_str","text":"Shorthand for instantiating excalidraw Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@graphviz_str-Tuple{AbstractString}","page":"API","title":"Kroki.@graphviz_str","text":"Shorthand for instantiating graphviz Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@mermaid_str-Tuple{AbstractString}","page":"API","title":"Kroki.@mermaid_str","text":"Shorthand for instantiating mermaid Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nomnoml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nomnoml_str","text":"Shorthand for instantiating nomnoml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nwdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nwdiag_str","text":"Shorthand for instantiating nwdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@packetdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@packetdiag_str","text":"Shorthand for instantiating packetdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@pikchr_str-Tuple{AbstractString}","page":"API","title":"Kroki.@pikchr_str","text":"Shorthand for instantiating pikchr Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@plantuml_str","text":"Shorthand for instantiating plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@rackdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@rackdiag_str","text":"Shorthand for instantiating rackdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@seqdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@seqdiag_str","text":"Shorthand for instantiating seqdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@structurizr_str-Tuple{AbstractString}","page":"API","title":"Kroki.@structurizr_str","text":"Shorthand for instantiating structurizr Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@svgbob_str-Tuple{AbstractString}","page":"API","title":"Kroki.@svgbob_str","text":"Shorthand for instantiating svgbob Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@umlet_str-Tuple{AbstractString}","page":"API","title":"Kroki.@umlet_str","text":"Shorthand for instantiating umlet Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vega_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vega_str","text":"Shorthand for instantiating vega Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vegalite_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vegalite_str","text":"Shorthand for instantiating vegalite Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@wavedrom_str-Tuple{AbstractString}","page":"API","title":"Kroki.@wavedrom_str","text":"Shorthand for instantiating wavedrom Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Private-1","page":"API","title":"Private","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"InvalidDiagramSpecificationError\nInvalidOutputFormatError\nLIMITED_DIAGRAM_SUPPORT\nUriSafeBase64Payload\nrender","category":"page"},{"location":"api/#Kroki.InvalidDiagramSpecificationError","page":"API","title":"Kroki.InvalidDiagramSpecificationError","text":"struct InvalidDiagramSpecificationError <: Exception\n\nAn Exception to be thrown when a Diagram representing an invalid specification is passed to render.\n\nFields\n\nerror::String\ncause::Diagram\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.InvalidOutputFormatError","page":"API","title":"Kroki.InvalidOutputFormatError","text":"struct InvalidOutputFormatError <: Exception\n\nAn Exception to be thrown when a Diagram is rendered to an unsupported or invalid output format.\n\nFields\n\nerror::String\ncause::Diagram\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.LIMITED_DIAGRAM_SUPPORT","page":"API","title":"Kroki.LIMITED_DIAGRAM_SUPPORT","text":"Some MIME types are not supported by all diagram types, this constant contains all these limitations. The union of all values corresponds to all supported Diagram types.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.UriSafeBase64Payload","page":"API","title":"Kroki.UriSafeBase64Payload","text":"UriSafeBase64Payload(diagram::Diagram) -> String\n\n\nCompresses a Diagram's specification using zlib, turning the resulting bytes into a URL-safe Base64 encoded payload (i.e. replacing + by - and / by _) to be used in communication with a Kroki service.\n\nSee the Kroki documentation for more information.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.render","page":"API","title":"Kroki.render","text":"render(diagram::Diagram, output_format::AbstractString) -> Array{UInt8,1}\n\n\nRenders a Diagram through a Kroki service to the specified output format.\n\nIf the Kroki service responds with an error throws an InvalidDiagramSpecificationError or InvalidOutputFormatError if a know type of error occurs. Other errors (e.g. HTTP.ExceptionRequest.StatusError for connection errors) are propagated if they occur.\n\n\n\n\n\n","category":"function"},{"location":"api/#Documentation-1","page":"API","title":"Documentation","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [ Kroki.Documentation ]","category":"page"},{"location":"api/#Kroki.Documentation","page":"API","title":"Kroki.Documentation","text":"Contains templates and a helper macro @setupDocstringMarkup to easily set up consistent docstring formats across modules.\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Documentation.@setupDocstringMarkup-Tuple{}","page":"API","title":"Kroki.Documentation.@setupDocstringMarkup","text":"Helper macro ensuring consistent docstring markup across modules through templating.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Service-Management-2","page":"API","title":"Service Management","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [ Kroki.Service ]\nOrder = [ :constant ]","category":"page"},{"location":"api/#Kroki.Service.DEFAULT_ENDPOINT","page":"API","title":"Kroki.Service.DEFAULT_ENDPOINT","text":"The default ENDPOINT to use, i.e. the publicly hosted version.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.Service.ENDPOINT","page":"API","title":"Kroki.Service.ENDPOINT","text":"The currently active Kroki service endpoint being used.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.Service.SERVICE_DEFINITION_FILE","page":"API","title":"Kroki.Service.SERVICE_DEFINITION_FILE","text":"Path to the Docker Compose definitions for running a local Kroki service.\n\n\n\n\n\n","category":"constant"},{"location":"api/#","page":"API","title":"API","text":"Kroki.Service.executeDockerCompose","category":"page"},{"location":"api/#Kroki.Service.executeDockerCompose","page":"API","title":"Kroki.Service.executeDockerCompose","text":"executeDockerCompose(cmd::Array{String,1}) -> String\n\n\nHelper function for executing Docker Compose commands.\n\nReturns captured stdout.\n\nThrows an ErrorException if Docker and/or Docker Compose aren't available. Throws a DockerComposeExecutionError if any other exception occurs during execution.\n\n\n\n\n\n","category":"function"},{"location":"#Kroki.jl-1","page":"Home","title":"Kroki.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"CurrentModule = Kroki","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Diagram from textual description generator for Julia.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"A package integrating Julia with Kroki, a service for generating diagrams from textual descriptions.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"using Kroki\nintroduction_visual = plantuml\"\"\"\nKroki -> Julia: I'm here to help.\nJulia -> Kroki: With what?\nKroki -> Julia: Rendering diagrams!\n\"\"\"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"introduction_visual #hide","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Kroki provides support for a wide array of diagramming languages such as Ditaa, Graphviz, Mermaid, PlantUML and many more. The package can be configured to use the publicly hosted server at https://kroki.io or self-hosted instances (see setEndpoint! for configuration instructions). A basic configuration file (docker-services.yml) for Docker Compose is available in the support folder of the package for those interested in self-hosting the service.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The aim of the package is to make it easy to integrate descriptive diagrams within code and docstrings (rendered as text), while upgrading the diagrams to good looking visuals whenever possible, e.g. in the context of Documenter or Jupyter/IJulia, using SVG or other output formats.","category":"page"},{"location":"#Contents-1","page":"Home","title":"Contents","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Pages = [ \"api.md\" ]","category":"page"}]
}
