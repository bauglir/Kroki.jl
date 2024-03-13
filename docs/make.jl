using Documenter, Kroki

const running_in_ci = get(ENV, "CI", nothing) == "true"

makedocs(
  authors = "Joris Kraak",
  modules = [Kroki],
  sitename = "Kroki.jl",
  pages = ["Home" => "index.md", "Examples" => "examples.md", "API" => "api.md"],
  warnonly = !running_in_ci,
)

if running_in_ci
  deploydocs(
    devbranch = "development",
    devurl = "latest",
    push_preview = true,
    repo = "github.com/bauglir/Kroki.jl.git",
  )
end
