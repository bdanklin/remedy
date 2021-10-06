
# Remedy

[![Publish Docs](https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/docs.yml) [![Codacy Security Scan](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml) [![Credo, ExDoc, Doctor, Dialyzer](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml)

Remedy is an elixir library for interracting with the [Discord API](https://discord.com/developers/docs/intro). The project began as a fork of the [Nostrum library](https://github.com/kraigie/nostrum)

## To Do

- [ ] Complete doc coverage
  - [ ] make doctests work
- [ ] Complete test coverage
- [x] new github actions
- [x] Convert structs to schema
- [x] Convert Cache to Ecto + Etso
- [x] use Gun as the only HTTP client
- [ ] Re implement voice
- [x] rewrite gateway modules
- [x] Code clean up to respect contexts
- [ ] smash morphix apart and just take the 1 function i use
- [ ] Remove config.exs

## Installation

```elixir
defp deps() do
  [
    {:remedy, "~> 0.6.4"}
  ]
end
```

## License
[MIT](https://opensource.org/licenses/MIT)
