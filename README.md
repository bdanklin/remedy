<img align="left" width="60" height="60" src="https://raw.githubusercontent.com/bdanklin/remedy/master/remedy.png">

# Remedy

[![Publish Docs](https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg?branch=master)](https://github.com/bdanklin/remedy/actions/workflows/docs.yml) [![Test & Lint](https://github.com/bdanklin/remedy/actions/workflows/test_and_lint.yml/badge.svg?branch=master)](https://github.com/bdanklin/remedy/actions/workflows/test_and_lint.yml) [![Codacy Security Scan](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml/badge.svg)](https://github.com/bdanklin/remedy/actions/workflows/codacy-analysis.yml)

Playground fork of Nostrum.

## Working on

- [ ] Remove the shard ETS table. use Registry instead.
- [ ] Separate applicable components into their own package.
  - [x] Bit Flag handler - https://hex.pm/packages/battle_standard
  - [x] Timestamp & Snowflake Ecto Types - https://hex.pm/packages/sunbake
- [x] Convert structs Schema.
- [x] Convert cache to Etso.
- [ ] Generalize cache.
  - [ ] Giving a library user the choice of what to cache is actually a huge pain it turns out.
  - [ ] Make it an actual cache, aka invisible and if the resource is not in cache, we should fetch it and return it as required.
- [ ] Testing
  - [ ] Doc Tests to run on Github Actions
  - [ ] Doc Tests to even run manually for a start would be 🔥
  - [ ] Supply a bot secret thru workflow to enable actual testing on a real server. without exposing secrets (prob too hard)
  - [ ] Display while running
    - [ ] https://hexdocs.pm/table_rex/TableRex.Table.html
    - [ ] https://github.com/henrik/progress_bar

## Installation

I do not recommend anybody install this, instead you should probably use [Nostrum](https://github.com/Kraigie/nostrum)

## License
[MIT](https://opensource.org/licenses/MIT)
