workspace {
  model {
    user = person "User"

    kroki_jl = softwareSystem Kroki.jl {
      description "A Julia interface to a 'Kroki Service'."

      library = container Kroki.jl {
        description "A Julia interface to a 'Kroki Service'."

        user -> this "Writes diagrams using"

        diagram = component Diagram {
          description "Facilitates definition and rendering of different diagram types."
        }

        service_management = component "Service Management" {
          description "Provides management over the 'Kroki Service' that is being used, including managing a local instance."
        }

        component "String Literals" {
          description "Provide an easier means of constructing diagrams."
        }
      }
    }

    kroki_service = softwareSystem "Kroki Service" {
      description "A collection of services behind a singular HTTP API, exposing a variety of textual diagramming tools.\n\nCan be publicly or privately hosted."

      kroki_core = container "Kroki Core" {
        description "Renders a subset of the supported diagrams itself. Defers to sidecontainers for other diagrams."
        url https://kroki.io

        library -> this "Sends encoded diagram to"
      }

      container "Blockdiag Service" {
        description "Renders diagrams from the `blockdiag` suite of generators, e.g. `blockdiag`, `seqdiag`, `actdiag`, `nwdiag`, etc."
        url http://blockdiag.com

        kroki_core -> this "Defers `blockdiag` diagrams to"
      }

      container "BPMN Service" {
        description "Renders 'Business Process Model and Notation' diagrams using `bpmn-js`."
        url https://bpmn.io/toolkit/bpmn-js

        kroki_core -> this "Defers `bpmn` diagrams to"
      }

      container "Excalidraw Service" {
        description "Renders 'Excalidraw' diagrams."
        url https://excalidraw.com

        kroki_core -> this "Defers `excalidraw` diagrams to"
      }

      container "Mermaid Service" {
        description "Renders 'Mermaid' diagrams."
        url https://mermaid-js.github.io

        kroki_core -> this "Defers `mermaid` diagrams to"
      }
    }
  }

  views {
    container kroki_jl {
      include *
      autoLayout lr
    }

    component library {
      include *
      autoLayout bt
    }

    container kroki_service {
      include *
      autoLayout tb
    }

    theme default
  }
}
