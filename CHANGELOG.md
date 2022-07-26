# Changelog

# [0.2.0](https://github.com/bauglir/Kroki.jl/compare/v0.1.0...v0.2.0) (2022-07-26)


### Bug Fixes

* **Service:** use list comprehension over repeated iterator for `status` ([391d61e](https://github.com/bauglir/Kroki.jl/commit/391d61eaa59635381b526424b85a63eb5ba174b7))
* **string-literal:** enable escaping the string interpolation sign ([950f46c](https://github.com/bauglir/Kroki.jl/commit/950f46cd2594e5d300868255985c747588f102fb))


### Features

* add 'support' for rendering to JPEG ([5d34345](https://github.com/bauglir/Kroki.jl/commit/5d34345664ec9761200d03e9d60ee1d488f8fd18))
* add (experimental) support for `diagramsnet` ([dc12778](https://github.com/bauglir/Kroki.jl/commit/dc12778204b7e991350383345f02ea16226542f9))
* add `render` to the public API ([52f1698](https://github.com/bauglir/Kroki.jl/commit/52f169811f1ed4a07ff4f581dd2660c441cafe4f)), closes [#8](https://github.com/bauglir/Kroki.jl/issues/8)
* add support for rendering to PDF ([c8fce60](https://github.com/bauglir/Kroki.jl/commit/c8fce60f53e6c72e302b999fb096b5c67feab224))
* **Diagram:** add `options` controlling appearance ([ec380ba](https://github.com/bauglir/Kroki.jl/commit/ec380ba19e8fa2970121fdf041ea5e9737210954))
* **Diagram:** enable loading specifications from files ([58a880e](https://github.com/bauglir/Kroki.jl/commit/58a880ed57caace8c7a8b5bd50e7c7a207eb0312))
* enable `structurizr` rendering to plain text and JPEG ([289e9d7](https://github.com/bauglir/Kroki.jl/commit/289e9d7f7c116482d9e9f2fdc9a92db76ab06e9c))
* expose control over ASCII or Unicode rendering for `text/plain` MIME type ([5994a88](https://github.com/bauglir/Kroki.jl/commit/5994a8870cfc73ee23a62383c34c003f975f3389))
* make public API available without `Kroki` prefix ([1a95734](https://github.com/bauglir/Kroki.jl/commit/1a95734442785ff0319e16b57b3eec86b13615b0))
* **mermaid:** enable rendering to PNG ([da6dd23](https://github.com/bauglir/Kroki.jl/commit/da6dd23d2c499ee2a386fb4906bd547ac2f52a9d))
* **render:** accept `options` to modify rendering behavior ([5e7f1d7](https://github.com/bauglir/Kroki.jl/commit/5e7f1d7ccdfa601734d5d2ef865e6f7421141ae2))
* **service:** add `diagramsnet` to local service management ([19764fb](https://github.com/bauglir/Kroki.jl/commit/19764fb5003b4757dabda44899022cca52bb1a19))
* **Service:** add `info` function reporting on versions, etc. ([0d362b5](https://github.com/bauglir/Kroki.jl/commit/0d362b5eaf843cad1f738fd029ac1b868fb11ed9))
* **Service:** add `setEndpoint!` for explicit `ENDPOINT` manipulation ([a06f767](https://github.com/bauglir/Kroki.jl/commit/a06f767bcc290995b0cb7e4dc013800cee7b5bd6))
* **Service:** add `start!` for starting a local Kroki service ([9f0fe24](https://github.com/bauglir/Kroki.jl/commit/9f0fe24911f32c51561cb4eeed29516338b8fe15))
* **Service:** add `status` for inspecting local service instance ([6ac73f5](https://github.com/bauglir/Kroki.jl/commit/6ac73f52241f4991e64567980c0db83a3914985d))
* **Service:** add `stop!` for stopping running Kroki service components ([0c652ec](https://github.com/bauglir/Kroki.jl/commit/0c652eca13e425fb27c1f880f845099f39bc48b5))
* **Service:** add `update!` for pulling latest service component Docker images ([0b90217](https://github.com/bauglir/Kroki.jl/commit/0b902179b804337ca739134a963e19da33973128))
* **Service:** add basic Docker Compose file for local Kroki services ([fd690f5](https://github.com/bauglir/Kroki.jl/commit/fd690f500a01e41801fe5bf6b009aeed265c2be2))
* **Service:** throw descriptive errors for Docker Compose execution ([b22f1f2](https://github.com/bauglir/Kroki.jl/commit/b22f1f2619363b4b7c3969a70a31ebbf4bbef0a0))
* **string-literal:** show 'friendly' names in docstrings ([eb94fb0](https://github.com/bauglir/Kroki.jl/commit/eb94fb0c3127bdbb256fbc90058a033c6122a01f))
* support 'bytefield' diagrams ([14245b9](https://github.com/bauglir/Kroki.jl/commit/14245b953c8648766f07c9d0dfc05e7aa95dc426))
* support Business Process Model and Notation (BPMN) diagrams ([6a718fd](https://github.com/bauglir/Kroki.jl/commit/6a718fd396a6a7380fa462537ff66a2ba2693993))
* support Excalidraw diagrams ([e478fb3](https://github.com/bauglir/Kroki.jl/commit/e478fb38814fe747b29d0d6572aee138a99c307e))
* support Pikchr diagrams ([83aeee9](https://github.com/bauglir/Kroki.jl/commit/83aeee98c0a752fe9221f8b4a8f36a8a76220ff1))
* support string interpolation for diagram string literals ([d95f4d3](https://github.com/bauglir/Kroki.jl/commit/d95f4d359c50ae1394ea5cc1e4f6d0223873a1bc))
* support Structurizr diagrams ([237455e](https://github.com/bauglir/Kroki.jl/commit/237455e914c359ad8645958a7c617b23623334be))

# 0.1.0 (2020-07-23)

### Bug Fixes

* bump minimum Julia requirement to v1.3 ([3bb9754](https://github.com/bauglir/Kroki.jl/commit/3bb97545a83819fd9260c191667962c7dbb732c8))

### Features

* Diagram: add Base.show method for image/png output ([dd52e58](https://github.com/bauglir/Kroki.jl/commit/dd52e5875cc6436a40fbec375563a0d84011d600))
* Diagram: add Base.show method for image/svg+xml output ([dc10da7](https://github.com/bauglir/Kroki.jl/commit/dc10da7413bdb1b0a5df02c3a995dcb8ba64eb1c))
* Diagram: add rendering through publicly hosted service ([f04b1b3](https://github.com/bauglir/Kroki.jl/commit/f04b1b369835393ec87c103db7017c59c4ee7763))
* Diagram: add canonical diagram representation ([f1e909c](https://github.com/bauglir/Kroki.jl/commit/f1e909c0c2b00899b2d7f877c59b40af2bab8db3))
* Diagram: add shorthand string literal syntax for instantiation ([70c08be](https://github.com/bauglir/Kroki.jl/commit/70c08bef9d661987a8414c3f4b37fcb2c70af4fc))
* PlantUML: improve rendering to plain text ([088854c](https://github.com/bauglir/Kroki.jl/commit/088854c36a1d0324611de7fa6077349ff4b06ac9))
* render: specify Kroki instance through KROKI_ENDPOINT environment variable ([ff2e560](https://github.com/bauglir/Kroki.jl/commit/ff2e560720d8af132494ec8878e4a96941f0bc0c))
* render: throw descriptive errors for invalid diagram specifications ([761c4ce](https://github.com/bauglir/Kroki.jl/commit/761c4cec9e1d7f9a0a71aea09f28abe8817eeb74))
* render: throw descriptive errors for invalid or unknown output formats ([bfe6915](https://github.com/bauglir/Kroki.jl/commit/bfe69156c94a9d1282925ae6db1cf313815d542e))
