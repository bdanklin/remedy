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

#### Options

  - `:all` - All intents will be subscribed to.
    ```elixir
    config :remedy,
      gateway_intents: :all,
    ```

  - `value` - `:integer` - The value of the intents to subscribe to.
    ```elixir
    config :remedy,
      gateway_intents: 14275,
      ```


  -  `[:intent, :intent, ...]` - A list of intents to subscribe to, eg. `:GUILDS, :GUILD_MEMBERS, :GUILD_BANS`

      ```elixir
      config :remedy,
        gateway_intents: [:GUILDS, :GUILD_MEMBERS, :GUILD_BANS],
      ```

  The valid intents and their associated events are shown below:


## Using Remedy with Phoenix

If you are using Phoenix or any other library that requires Cowlib 2.11. also add the following to your deps

```elixir
defp deps do
  [
    {:cowlib, "~> 2.11", hex: :remedy_cowlib, override: true}
  ]
end
```

Directly (Phoenix), or indirectly (Remedy, via Gun), both of these libraries require Cowlib.

Discord is notorious for misbehaving in regards to RFC7230 3.3.2. and conversely, Cowlib is notorious for strictly adhering to this proposed standard, some of discords responses are an almost correct 204 response which cause the official Cowlib to raise frequently, crashing our consumer.

Remedy uses patched versions of both of these libraries. Gun is the same as the 2.0rc at the time of publishing, and Cowlib is patched to remove the strict adherance to RFC7230. It is completely backwards compatible with the regular Cowlib 2.11 published on hex. Except it will not raise in the case of diversion from the standard. It will pass through values regardless, which is what we need to handle discords empty 204 responses.
