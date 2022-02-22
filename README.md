<img align="center" src="remedy_banner.png">

---
\
[![Publish Docs](https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/docs.yml) [![Codacy Security Scan](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml) [![Credo, ExDoc, Doctor, Dialyzer](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml)

Remedy is an elixir library for interracting with the [Discord API](https://discord.com/developers/docs/intro). It supports both the Gateway and REST API.

The project began as an experimental fork of the [Nostrum library](https://github.com/kraigie/nostrum), Which I have also contributed to from time to time. However as the scope of the changes grew it became clear that it was too much to push upstream into Nostrum. At the time of writing the entire library has been re-written.

If you would like a more widely used and supported library check them out on [Github](https://github.com/kraigie/nostrum) or on the [Unofficial Discord API Server](https://discord.gg/discord-api)

## Installation

```elixir
defp deps() do
  [
    {:remedy, "~> 0.6.9"}
  ]
end
```

## Supporting Libraries

A number of issues plagued Elixir libraries using the Discord API. Rather than wait for upstream fixes either from Cowlib or Discord respectively I have published patched versions of gun and cowlib which alleviate these issues. They are included by default, however if you encounter dependency clashes you should override them using the below libraries.

More information can be found in the documentation.

```elixir
defp deps() do
  [
    # ... your other deps
    {:gun, hex: :remedy_gun, "2.0.1"},
    {:cowlib, hex: :remedy_cowlib, "2.11.1"}
  ]
end
```
## Links

- [Hex]()
- [HexDocs]()
- [Github]()

## License
[MIT](https://opensource.org/licenses/MIT)
