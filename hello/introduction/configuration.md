# Configuration

Remedy provides a felxible system for configuration.

When configuring Remedy you can provide secrets and configuration as any (or a combination of) the following ways.

- `.env` file in your root folder. This is typically where you would store your envorionment variables and then use a command like `source` in bash to load them into your shell. This should only be used for local development.
- Environment variables. For situations where your secrets are loaded into your environment by some external service, such as [Vault](https://www.vaultproject.io/), [Google Secret Manager](https://cloud.google.com/secret-manager) or [Fly](https://fly.io/docs/reference/secrets/).
- `config.exs` and friends. This is the standard way to configure applications in Elixir.
- Function arguments. This can only be used when starting the supervision tree manually.

If you supply the same configuration argument in multiple places it will be taken as the value from the following heirarchy

    args   >   config.exs   >   environment variables   >   .env

Let's look at what we can configure and how it should be done. This table shows the who, where and when for each of the parameters able to be configured within Remedy.

| env                    | config           | args             | default      |
| ----                   | ----             | ----             | ----         |
| `"REMEDY_EMBEDDED"`    | `:embedded`      |                  | `true`       |
| `"REMEDY_TOKEN"`       | `:token`         | `:token`         |              |
| `"REMEDY_SECRET"`      | `:secret`        | `:secret`        |              |
| `"REMEDY_INTENTS"`     | `:intents`       | `:intents`       | `:auto`      |
| `"REMEDY_SHARDS"`      | `:shards`        | `:shards`        | `:auto`      |
| `"REMEDY_WORKERS"`     | `:workers`       | `:worker`        | `:auto`      |
|                        | `:cache`         | `:cache`         | `:auto`      |
|                        | `:debug`         | `:debug`         | `:auto`      |
|                        |                  | `:id`            | `__MODULE__` |

## Embedded

- `true` (default). This is the simplest way to start Remedy. In cases where your application is just a bot this is the easiest way to get started.
- `false` indicates to Remedy that it should **Not** start as part of the application supervision tree. It then becomes your responsibility to start and supervise the process.

This functionality can be useful in situations where you need strict control in the way your application starts an example of which is a Nerves device, where there can be a need to hold starting Remedy until there is an internet connection available.

It can also be used in situations where you wish to dynamically provide the token and launch multiple instances of Remedy.

> #### Info {: .info}
>
> `embedded: false` is the **only** time `:token` can be left unconfigured and passed to `start_link/2` manually. If you fail to configure a token your application will not start.


## Token

The token is your bots password. It can be retreived from your [Application Dashboard](https://discord.com/developers/applications). Providing a token is mandatory.

> #### Caution {: .warning}
>
> - Remedy does not support _self-botting_. Supplying a user token will break your computer and result in the application failing to start.

<!-- ![image](https://user-images.githubusercontent.com/34633373/155505628-14f89b83-1574-4781-99f9-592a63876bc3.png) -->


## Secret

The client secret is used with OAuth2. It can be retreived from your [Application Dashboard](https://discord.com/developers/applications).

<!-- ![image](https://user-images.githubusercontent.com/34633373/155505905-c27d1a46-c208-4a5a-974b-c2c6b4ec7941.png) -->


## Intents
Intents are how you tell the gateway which events you want to subscribe to.

- `:auto` - By default all events will be requested.
- `integer` - Manually selecting Gateway Intents allow you to limit the events that you will receive from the Gateway.
-  `[:intent, :intent, ...]` - A list of intents to subscribe to.

Providing a list is only valid when using `config.exs` or when supplying the intents as an argument to the supervision tree.

```elixir
config :remedy,
  token: System.get_env("REMEDY_TOKEN")
  gateway_intents: [:GUILDS, :GUILD_MEMBERS, :GUILD_BANS]
```

This is useful to limit the events you receive. For example if your bot is only interested in certain events you can configure the intents to only request those events from the gateway. More information and a calculator can be found on [ziad87 Intents Calculator](https://ziad87.net/intents/).

## Shards
The limit of shards to connect to the gateway.

- `:auto` (default)

Discord recommend 1 shard per 1000 guilds. However we can shard whenever we like to achieve true load balancing. . This is great for Elixir due to the concurrent processing capabilities. By default the shards will auto scale based on the load. Spawning more shards as required.

Overriding this value should be considered for development, debugging, or testing only.

## Workers
The limit of HTTP connections to have open at any one time.

- `:auto` (default)
- `integer` For more information see [Connection Limits](#connection-limits)

<!-- ## Cache ## Debug ## ID -->


## Further Reading


### Environment Variables
It is recommended to use environment variables to store sensitive configuration to ensure they are not exposed if you should upload your project to GitHub etc. If a token is uploded to a public repo, Discord will notice and invalidate it.

To configure your application using a `.env` file place it in the root of your application.

```$
export REMEDY_TOKEN="QV9WZXJ5X05pY2VfVG9rZW5fSGlfSG93X0FyZV9Zb3U="
```

Referencing the environment variables inside your `config.exs` will then be

```elixir
config :remedy
  token: System.get_env("REMEDY_TOKEN")
```

### Connection Limits
Some hosting platforms will limit the number of connections you are allowed to keep active at any one time.

Each shard and HTTP2 worker will count for an individual connection. In addition to any other connections required for your application. For example, a default Phoenix application will establish 10 connections to the database. If you are using Heroku free tier (20 connection limit) you could run out of connections for users visiting your web application. In those cases you could consider limiting the number of shards and HTTP2 workers, however, this solution is only suitable for small projects.

We recommend using [Gigalixir](https://www.gigalixir.com/) or [Fly.io](https://fly.io/) for your hosting platform. The gigalixir free tier has unlimited connections and will allow your bot to run automatically configured shards without issues.
