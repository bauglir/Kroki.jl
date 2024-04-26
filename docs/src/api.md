# API

```@meta
CurrentModule = Kroki
```

## Public

```@docs
Kroki
Diagram
Diagram(::Symbol, ::AbstractString)
Diagram(::Symbol; ::Union{Nothing,AbstractString}, ::Union{Nothing,AbstractString})
SUPPORTED_TEXT_PLAIN_SHOW_MIME_TYPES
TEXT_PLAIN_SHOW_MIME_TYPE
overrideShowable
render
resetShowableOverrides
```

### Service Management

```@autodocs
Modules = [ Kroki.Service ]
Order = [ :module, :type, :function ]
Filter = name -> "$name" !== "executeDockerCompose"
```

### [String Literals](@id api-string-literals)

The following string literals are exported from the [`Kroki`](@ref) module to
make it more straightforward to instantiate `Diagram`s.

```@autodocs
Modules = [ Kroki.StringLiterals ]
Order = [ :module, :macro ]
```

## Private

```@docs
DiagramTypeMetadata
DIAGRAM_TYPE_METADATA
LIMITED_DIAGRAM_SUPPORT
MIME_TO_RENDER_ARGUMENT_MAP
SHOWABLE_OVERRIDES
UriSafeBase64Payload
getDiagramTypeMetadata
normalizeDiagramType
```

### Documentation

```@autodocs
Modules = [ Kroki.Documentation ]
```

### Exceptions

```@autodocs
Modules = [ Kroki.Exceptions ]
```

### Service Management

```@autodocs
Modules = [ Kroki.Service ]
Order = [ :constant ]
```

```@docs
Kroki.Service.executeDockerCompose
```

### String Literals

```@autodocs
Modules = [ Kroki.StringLiterals ]
Order = [ :function ]
```
