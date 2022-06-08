# Getting Started

A basic configuration for Remedy is shown below

```elixir
import Config

config :remedy,
  token: System.get_env("REMEDY_BOT_TOKEN"),
  gateway_intents: :all,
  log_dispatch_events: true
```

### Token
The token can be hardcoded or set as an environment variable. it can be retreived from your [Application Dashboard](https://discord.com/developers/applications)

### Gateway Intents
When connecting to the gateway, the intents must be specified, which will determine which events are subscribed to. You can specify which intents should be subscribed to by setting your application configuration appropriately.

To calculate the integer value, there are a number of community made intents calculators, such as [this one](https://ziad87.net/intents/)


## Using Remedy with Phoenix

If you are using Phoenix or any other library that requires Cowlib 2.11. also add the following to your deps

```elixir
defp deps do
  [
    {:cowlib, "~> 2.11", hex: :remedy_cowlib, override: true}
  ]
end
```
