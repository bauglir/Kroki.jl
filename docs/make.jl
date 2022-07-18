using Documenter, Kroki

makedocs(
  authors = "Joris Kraak",
  modules = [Kroki],
  sitename = "Kroki.jl",
  pages = ["Home" => "index.md", "Examples" => "examples.md", "API" => "api.md"],
  strict = true,
)

if get(ENV, "CI", nothing) == "true"
  deploydocs(
    devbranch = "development",
    devurl = "latest",
    push_preview = true,
    repo = "github.com/bauglir/Kroki.jl.git",
  )
end
