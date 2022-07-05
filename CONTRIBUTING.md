# Contributing

The [![ColPrac: Contributor's Guide on Collaborative Practices for Community
Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://colprac.sciml.ai/)
serves as the basis for contributions to this project. Some additional
guidelines are described in the rest of this document.

This project goes slightly further than [Semantic
Versioning](https://semver.org), as mandated by
[Pkg.jl](https://julialang.github.io/Pkg.jl), and uses the [Semantic
Release](https://semantic-release.gitbook.io) framework for release management.
This puts tight restrictions on the [format of commit
messages](https://semantic-release.gitbook.io/semantic-release/#commit-message-format),
as those are used to determine the version number of a new release and to
generate the CHANGELOG.

## Commit and Branching Strategy

New functionality and bugfixes tend to be released in batches, this is
supported by the branching strategy. The `main` branch contains all (and only)
releases, the `development` branch should be considered the 'next' release and
to be, at least relatively, stable.

Feature branches and corresponding pull requests are used for getting change
proposals to the codebase into shape. Their commit messages (at least those
that are CHANGELOG facing) should communicate a clear narrative for their
respective changes. This makes it easier for users of the package to learn
about changes new versions introduce without having to dig through the
codebase.

In general, commit messages should indicate _why_ a change is implemented! This
rule is flexible in light of trivial changes (e.g. correcting typos), but one
should err on the side of including an explanation.

Branches are merged using non-fast-forward merges and need to be rebased with
respect to their target branch just prior to merging. Feature branches do not
tend to be squashed, but may be rebased to provide a clear narrative. When
rebasing, keep in mind whether others may have the branch checked out (e.g.
when collaborating on a feature).

## Building the documentation

Kroki's documentation is build using
[`Documenter`](https://github.com/JuliaDocs/Documenter.jl). To build it run

```sh
julia --project=docs docs/make.jl
```

When working on the documentation, the
[LiveServer](https://github.com/tlienart/LiveServer.jl) package may come in
useful to automatically rebuild and reload documentation. To use it:

* `julia --project=docs --eval 'using Pkg; Pkg.add("LiveServer")'`
* `julia --project=docs --eval 'using LiveServer, Kroki; servedocs()'`

When installing `LiveServer`, make sure _not_ to commit the respective changes
to the `docs/Manifest.toml`.

The most recent documentation for releases or the `development` branch is
always build in CI.

### Troubleshooting

To be able to build Kroki's documentation for every version, and especially
during development, the `docs` project needs to be aware of the package. To
achieve this it is added as a regular dependency of the `docs` project using a
relative path in the `docs/Manifest.toml`.

In case errors occur while building the documentation, such as new modules or
functions not being found, make sure this path has not accidentally been
updated (e.g. to refer to a release of Kroki instead).

Should such a situation occur make sure that Kroki's decleration in the
`docs/Manifest.toml` includes a `path` set to `".."`, instead of a
`git-tree-sha1` or a `version`.
