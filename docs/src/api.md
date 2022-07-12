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
render
```

### Service Management

```@autodocs
Modules = [ Kroki.Service ]
Order = [ :module, :type, :function ]
Filter = name -> "$name" !== "executeDockerCompose"
```

### [String Literals](@id api-string-literals)
```@autodocs
Modules = [ Kroki ]
Order = [ :macro ]
Filter = m -> endswith("$m", "_str")
```

## Private

```@docs
DiagramPathOrSpecificationError
InvalidDiagramSpecificationError
InvalidOutputFormatError
LIMITED_DIAGRAM_SUPPORT
UriSafeBase64Payload
```

### Documentation

```@autodocs
Modules = [ Kroki.Documentation ]
```

### Service Management

```@autodocs
Modules = [ Kroki.Service ]
Order = [ :constant ]
```

```@docs
Kroki.Service.executeDockerCompose
```
