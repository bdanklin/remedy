# Remedy

[![Publish Docs](https://github.com/bdanklin/remedy/actions/workflows/docs.yml/badge.svg?branch=master)](https://github.com/bdanklin/remedy/actions/workflows/docs.yml) [![Test & Lint](https://github.com/bdanklin/remedy/actions/workflows/test_and_lint.yml/badge.svg?branch=master)](https://github.com/bdanklin/remedy/actions/workflows/test_and_lint.yml)

Playground fork of Nostrum discord library.

I am still using [Nostrum](https://github.com/Kraigie/nostrum) for my bots and I recommend you do the same. This is just a playground.


## Goals

- Gun 2.0
- Separate applicable components into their own packages.
- Organise types - Timestamp / Snowflake
- Convert structs to schema to...
  - Make the casting easier.
  - Make storing them in a db easier.
  - Prevent the end user re modelling these things for their own db.
- Convert cache to Etso.
  - integrate nicely with new schema.
- Generalize cache.
  - Choose what to cache. eg i only want to cache user presence and message embeds...
  - Make it an actual cache, aka invisible and if the resource is not in cache, we should fetch it and return it as required.
- Testing
  - Supply a bot secret thru workflow to enable actual testing on a real server. without exposing secrets (prob too hard)
- Bang functions?!?
  - Remove all the bloaty manual stuff. Include a generic unsafe.


## Packages

I have extracted various components from the codebase which in my opinion are cluttering the code with static helpers at various layers of abstraction. You are welcome to use them and submit any improvements you find.

- [Sunbake](https://hex.pm/packages/sunbake) For easy types. Timestamp and Snowflake currently included.
- [Battle Standard](https://hex.pm/packages/battle_standard) Clean up all those manual flag helpers. just `use BattleStandard`
