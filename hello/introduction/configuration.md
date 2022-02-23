# Advanced Configuration

Remedy provides a felxible system for configuration. You can provide secrets as
either environment variables, using `Config`, or by providing the values when
starting the supervision tree manually. Let's look at what we can configure.

## Values

The available configuration are shown in the following table.

| env                           | config             | args               |
| ----                          | ----               | ----               |
| `"REMEDY_TOKEN"`              | `:token`           | `:token`           |
| `"REMEDY_EMBEDDED"`           | `:embedded`        |  n/a               |
| `"REMEDY_GATEWAY_INTENTS"`    | `:gateway_intents` | `:gateway_intents` |
| `"REMEDY_GATEWAY_SHARDS"`     | `:gateway_shards`  | `:gateway_shards`  |
| `"REMEDY_MIN_WORKERS"`        | `:min_workers`     | `:min_workers`     |
| `"REMEDY_MAX_WORKERS"`        | `:max_workers`     | `:max_workers`     |

### Token
The token can be retreived from your [Application Dashboard](https://discord.com/developers/applications). The token is mandatory.

### Embedded

- `false` (default)
- `true` - This will indicate to Remedy **Not** to start as part of the application supervision tree. It will be your responsibility to start and supervise the process should you enable this option.

This functionality is useful in situations such as running Remedy on a Nerves device. In which case you need to delay the starting of Remedy until there is an internet connection available.

> #### Caution {: .warning}
>
> It can also be used in situations where you wish to dynamically provide the token and launch multiple instances of Remedy. This functionality should only be used if you know what you are doing. (I don't know what I'm doing)

> #### Caution {: .warning}
>
> `embedded: true` is the **only** time `:token` can be left unconfigured and passed to `start_link/2` manually.

### Gateway Intents

- `:auto` - (default) By default all events will be requested.
- `integer` - Manually selecting Gateway Intents allow you to limit the events that you will receive from the Gateway.

### Gateway Shards
The number of shards to connect. Discord recommend 1 shard per 1000 guilds. However we can shard whenever we like. This is great for Elixir due to the concurrent processing capabilities. By default the shards will auto scale based on the load. We will also run one Dispatch Producer per Shard.

### Workers
The workers are the persistent HTTP Connections used for the API connection pool. By default we will keep 10 connections alive and scale it based on API usage. For more information see [Connection Limits](#connection-limits)


## Heirarchy

The heirarchy of configuration values is

    Arguments   >  Config   >  Environment Variables

That is if you set a config value and an environment variable, the environment variable will be ignored.


### Environment Variables
In all cases it is recommended to use environment variables to store sensitive configuration. So that they are not exposed if you should upload your project to GitHub etc. If a token is uploded to a public repo, Discord will notice and invalidate it.

To configure your application using a `.env` file place it in the root of your application. It will look something like this:
```
export REMEDY_GATEWAY_INTENTS="all"
export REMEDY_MIN_WORKERS="2"
export REMEDY_MAX_WORKERS="2"
export REMEDY_GATEWAY_SHARDS="1"
```

Referencing the environment variables inside your `config.exs` will look something like

```elixir
import Config

config :remedy
  token: System.get_env("REMEDY_TOKEN")

```


## Connection Limits
Some hosting platforms will limit the number of connections you are allowed to keep active at any one time.
Each shard and HTTP2 worker will count for an individual connection. In addition to any other connections required for your application. Phoenix will establish 10 connections to the database by default. If you are using Heroku free tier (20 connection limit) you could run out of connections for users visiting your web application. In those cases you should consider limiting the number of shards and HTTP2 workers.
We recommend using [Gigalixir](https://www.gigalixir.com/) or [Fly.io](https://fly.io/) for your hosting platform. The gigalixir free tier has unlimited connections and will allow your bot to run automatically configured shards without issues.
