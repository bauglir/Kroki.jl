# API

```@meta
CurrentModule = Kroki
```

## Public

```@docs
Kroki
Diagram
```

### Service Management

```@autodocs
Modules = [ Kroki.Service ]
Order = [ :module, :type, :function ]
Filter = name -> "$name" !== "executeDockerCompose"
```

### Shorthands

```@autodocs
Modules = [ Kroki ]
Order = [ :macro ]
Filter = m -> endswith("$m", "_str")
```

## Private

```@docs
InvalidDiagramSpecificationError
InvalidOutputFormatError
LIMITED_DIAGRAM_SUPPORT
UriSafeBase64Payload
render
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
