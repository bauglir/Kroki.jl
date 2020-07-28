var documenterSearchIndex = {"docs":
[{"location":"api/#API-1","page":"API","title":"API","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"CurrentModule = Kroki","category":"page"},{"location":"api/#Public-1","page":"API","title":"Public","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Kroki\nDiagram","category":"page"},{"location":"api/#Kroki.Kroki","page":"API","title":"Kroki.Kroki","text":"The main Module containing the necessary types of functions for integration with a Kroki service.\n\nDefines Base.show and corresponding Base.showable methods for different output formats and Diagram types, so they render in their most optimal form in different environments (e.g. the documentation system, Documenter output, Jupyter, etc.).\n\n\n\n\n\n","category":"module"},{"location":"api/#Kroki.Diagram","page":"API","title":"Kroki.Diagram","text":"A representation of a diagram that can be rendered by a Kroki service.\n\nspecification::AbstractString\nThe textual specification of the diagram\ntype::Symbol\nThe type of diagram specification (e.g. ditaa, Mermaid, PlantUML, etc.). This value is case-insensitive.\n\nExamples\n\njulia> Kroki.Diagram(:PlantUML, \"Kroki -> Julia: Hello Julia!\")\n     ┌─────┐          ┌─────┐\n     │Kroki│          │Julia│\n     └──┬──┘          └──┬──┘\n        │ Hello Julia!   │\n        │───────────────>│\n     ┌──┴──┐          ┌──┴──┐\n     │Kroki│          │Julia│\n     └─────┘          └─────┘\n\n\n\n\n\n","category":"type"},{"location":"api/#","page":"API","title":"API","text":"Modules = [ Kroki ]\nOrder = [ :macro ]\nFilter = m -> endswith(\"$m\", \"_str\")","category":"page"},{"location":"api/#Kroki.@actdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@actdiag_str","text":"Shorthand for instantiating actdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@blockdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@blockdiag_str","text":"Shorthand for instantiating blockdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@c4plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@c4plantuml_str","text":"Shorthand for instantiating c4plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@ditaa_str-Tuple{AbstractString}","page":"API","title":"Kroki.@ditaa_str","text":"Shorthand for instantiating ditaa Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@erd_str-Tuple{AbstractString}","page":"API","title":"Kroki.@erd_str","text":"Shorthand for instantiating erd Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@graphviz_str-Tuple{AbstractString}","page":"API","title":"Kroki.@graphviz_str","text":"Shorthand for instantiating graphviz Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@mermaid_str-Tuple{AbstractString}","page":"API","title":"Kroki.@mermaid_str","text":"Shorthand for instantiating mermaid Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nomnoml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nomnoml_str","text":"Shorthand for instantiating nomnoml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@nwdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@nwdiag_str","text":"Shorthand for instantiating nwdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@packetdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@packetdiag_str","text":"Shorthand for instantiating packetdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@plantuml_str-Tuple{AbstractString}","page":"API","title":"Kroki.@plantuml_str","text":"Shorthand for instantiating plantuml Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@rackdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@rackdiag_str","text":"Shorthand for instantiating rackdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@seqdiag_str-Tuple{AbstractString}","page":"API","title":"Kroki.@seqdiag_str","text":"Shorthand for instantiating seqdiag Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@svgbob_str-Tuple{AbstractString}","page":"API","title":"Kroki.@svgbob_str","text":"Shorthand for instantiating svgbob Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@umlet_str-Tuple{AbstractString}","page":"API","title":"Kroki.@umlet_str","text":"Shorthand for instantiating umlet Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vega_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vega_str","text":"Shorthand for instantiating vega Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@vegalite_str-Tuple{AbstractString}","page":"API","title":"Kroki.@vegalite_str","text":"Shorthand for instantiating vegalite Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Kroki.@wavedrom_str-Tuple{AbstractString}","page":"API","title":"Kroki.@wavedrom_str","text":"Shorthand for instantiating wavedrom Diagrams.\n\n\n\n\n\n","category":"macro"},{"location":"api/#Private-1","page":"API","title":"Private","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"InvalidDiagramSpecificationError\nInvalidOutputFormatError\nLIMITED_DIAGRAM_SUPPORT\nUriSafeBase64Payload\nrender","category":"page"},{"location":"api/#Kroki.InvalidDiagramSpecificationError","page":"API","title":"Kroki.InvalidDiagramSpecificationError","text":"An Exception to be thrown when a Diagram representing an invalid specification is passed to render.\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.InvalidOutputFormatError","page":"API","title":"Kroki.InvalidOutputFormatError","text":"An Exception to be thrown when a Diagram is rendered to an unsupported or invalid output format.\n\n\n\n\n\n","category":"type"},{"location":"api/#Kroki.LIMITED_DIAGRAM_SUPPORT","page":"API","title":"Kroki.LIMITED_DIAGRAM_SUPPORT","text":"Some MIME types are not supported by all diagram types, this constant contains all these limitations. The union of all values corresponds to all supported Diagram types.\n\n\n\n\n\n","category":"constant"},{"location":"api/#Kroki.UriSafeBase64Payload","page":"API","title":"Kroki.UriSafeBase64Payload","text":"UriSafeBase64Payload(diagram::Kroki.Diagram) -> String\n\n\nCompresses a Diagram's specification using zlib, turning the resulting bytes into a URL-safe Base64 encoded payload (i.e. replacing + by - and / by _) to be used in communication with a Kroki service.\n\nSee the Kroki documentation for more information.\n\n\n\n\n\n","category":"function"},{"location":"api/#Kroki.render","page":"API","title":"Kroki.render","text":"render(diagram::Kroki.Diagram, output_format::AbstractString) -> Array{UInt8,1}\n\n\nRenders a Diagram through a Kroki service to the specified output format.\n\nA KROKI_ENDPOINT environment variable can be set, specifying the URI of a specific instance of Kroki to use (e.g. when using a privately hosted instance). By default the publicly hosted service is used.\n\nIf the Kroki service responds with an error throws an InvalidDiagramSpecificationError or InvalidOutputFormatError if a know type of error occurs. Other errors (e.g. HTTP.ExceptionRequest.StatusError for connection errors) are propagated if they occur.\n\n\n\n\n\n","category":"function"},{"location":"#Kroki.jl-1","page":"Home","title":"Kroki.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"CurrentModule = Kroki","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Diagram from textual description generator for Julia.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"A package integrating Julia with Kroki, a service for generating diagrams from textual descriptions.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"using Kroki\nintroduction_visual = plantuml\"\"\"\nKroki -> Julia: I'm here to help.\nJulia -> Kroki: With what?\nKroki -> Julia: Rendering diagrams!\n\"\"\"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"introduction_visual #hide","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Kroki provides support for a wide array of diagramming languages such as Ditaa, Graphviz, Mermaid, PlantUML and many more. The package can be configured to use the publicly hosted server at https://kroki.io or self-hosted instances (see render for configuration instructions).","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The aim of the package is to make it easy to integrate descriptive diagrams within code and docstrings (rendered as text), while upgrading the diagrams to good looking visuals whenever possible, e.g. in the context of Documenter or Jupyter/IJulia, using SVG or other output formats.","category":"page"},{"location":"#Contents-1","page":"Home","title":"Contents","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Pages = [ \"api.md\" ]","category":"page"}]
}
