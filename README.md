<img align="left" width="60" height="60" src="https://raw.githubusercontent.com/bdanklin/remedy/master/remedy.png">

# Remedy

[![Publish Docs](https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/docs.yml) [![Codacy Security Scan](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml) [![Credo, ExDoc, Doctor, Dialyzer](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/ex_check.yml)

Remedy is an elixir library for interracting with the [Discord API](https://discord.com/developers/docs/intro). The project began as a fork of the [Nostrum library](https://github.com/kraigie/nostrum). However as the scope of the changes grew it became clear that it was too much to PR upstream into Nostrum. At the time of writing the entire library has been re-written.

## To Do

- [x] new github actions
- [x] Convert structs to schema
- [x] Convert Cache to Ecto + Etso
- [x] use Gun as the only HTTP client
- [x] rewrite gateway modules
- [x] Code clean up to respect contexts
- [x] Remove config.exs
- [ ] Re implement voice
- [ ] smash morphix apart and just take the 1 function i use
- [ ] Complete doc coverage
  - [ ] make doctests work
- [ ] Complete test coverage

## Installation

```elixir
defp deps() do
  [
    {:remedy, "~> 0.6.8"}
  ]
end
```

## License
[MIT](https://opensource.org/licenses/MIT)
