# API

```@meta
CurrentModule = Kroki
```

## Public

```@docs
Kroki
Diagram
```

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
