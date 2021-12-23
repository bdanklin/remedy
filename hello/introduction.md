
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
    {:remedy, "~> 0.6.8"}
  ]
end
```
## Configuration

### Intents

###

## Using Remedy with Phoenix

Directly (Phoenix), or indirectly (Remedy, via Gun), both of these libraries require Cowlib.

Discord is notorious for misbehaving in regards to RFC7230 3.3.2. and conversely, Cowlib is notorious for strictly adhering to this proposed standard, some of discords responses are an almost correct 204 response which cause the official Cowlib to raise frequently, crashing our consumer.

Remedy uses patched versions of both of these libraries. Gun is the same as the 2.0rc at the time of publishing, and Cowlib is patched to remove the strict adherance to RFC7230. It is completely backwards compatible with the regular Cowlib 2.11 published on hex. Except it will not raise in the case of diversion from the standard. It will pass through values regardless, which is what we need to handle discords empty 204 responses.

### TL;DR.

If you are using Phoenix or any other library that requires Cowlib 2.11. also add the following to your deps

```elixir
defp deps do
  [
    {:cowlib, "~> 2.11", hex: :remedy_cowlib, override: true}
  ]
end
```


## License
[MIT](https://opensource.org/licenses/MIT)
