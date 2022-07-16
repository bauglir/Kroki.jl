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

The following string literals are exported from the [`Kroki`](@ref) module to
make it more straightforward to instantiate `Diagram`s.

```@autodocs
Modules = [ Kroki.StringLiterals ]
```

## Private

```@docs
LIMITED_DIAGRAM_SUPPORT
MIME_TO_RENDER_ARGUMENT_MAP
UriSafeBase64Payload
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
