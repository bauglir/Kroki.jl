using Documenter, Kroki

makedocs(
  authors = "Joris Kraak",
  sitename = "Kroki.jl",
  pages = ["Home" => "index.md", "API" => "api.md"],
)

if get(ENV, "CI", nothing) == "true"
  deploydocs(
    devbranch = "development",
    devurl = "latest",
    push_preview = true,
    repo = "github.com/bauglir/Kroki.jl.git",
  )
end
