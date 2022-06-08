<p align="center">
  <a href="https://github.com/bdanklin/remedy">
    <img alt="remedy" src="remedy_banner.png" width="435">
  </a>
</p>
<p align="center">
  <a href="https://hex.pm/packages/remedy">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/remedy.svg">
  </a>
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img alt="MIT License" src="https://img.shields.io/hexpm/l/remedy">
  </a>
</p>
<p align="center">
 <a href="https://github.com/bdanklin/remedy/actions/workflows/docs.yml">
    <img alt="Hex Version" src="https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg">
  </a>
   <a href="https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml">
    <img alt="Hex Version" src="https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml/badge.svg">
  </a>
   <a href="https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml">
    <img alt="Hex Version" src="https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml/badge.svg">
  </a>
</p>

<!-- MDOC -->

Remedy is an elixir library for interracting with the [Discord API](https://discord.com/developers/docs/intro). It supports both the events Gateway and REST API.

The project began as an experimental fork of the [Nostrum library](https://github.com/kraigie/nostrum), which I have also contributed to from time to time.
If you would like a more widely used and supported library check them out on [Github](https://github.com/kraigie/nostrum) or on the [Unofficial Discord API Server](https://discord.gg/discord-api)

However as the scope of the changes grew it became clear that it was too much to push upstream into Nostrum and decided to release it separately. At the time of writing the entire library has been re-written. The primary interfaces will be familiar to anyone who has used Nostrum.

## Installation
Add remedy to your deps.

```elixir
defp deps() do
  [
    {:remedy, "~> 0.6.9"}
  ]
end
```
## Configuration
This is the most basic configuration example.

```elixir
config :remedy,
  token: "Nzg2NTkzNjUyMzAxMzY1MjQ5.X9IqbA.1sMfTqLa0C2fnWBcKNF865lsGpA"
```
For more advanced configuration see the guides.

## Supporting Libraries

A number of issues plagued Discord libraries written in Elixir. Rather than wait for upstream fixes either from Cowlib, Gun or Discord respectively I have published patched versions of gun and cowlib which alleviate these issues. They are included by default, however if you encounter dependency clashes you should override them using the below libraries.

More information can be found in the documentation.

```elixir
defp deps() do
  [
    ...
    {:gun, hex: :remedy_gun, "2.0.1"},
    {:cowlib, hex: :remedy_cowlib, "2.11.1"}
  ]
end
```

<!-- MDOC -->

## Links

- [Hex]()
- [HexDocs]()
- [Github]()

## License
[MIT](https://opensource.org/licenses/MIT)
