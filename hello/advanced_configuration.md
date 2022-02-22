# Advanced Configuration

Remedy provides a felxible system for configuration. You can provide secrets as
either environment variables, using `Config`, or by providing the values when
starting the supervision tree manually.

The heirarchy of configuration values is

    Arguments   >  Config   >  Environment Variables

That is if you set a config value and an environment variable, the environment variable will be ignored. The available configuration are

| env                           | config             | args               |
| ----                          | ----               | ----               |
| `"REMEDY_TOKEN"`              | `:token`           | `:token`           |
| `"REMEDY_EMBEDDED"`           | `:embedded`        |  n/a               |
| `"REMEDY_GATEWAY_INTENTS"`    | `:gateway_intents` | `:gateway_intents` |
| `"REMEDY_GATEWAY_SHARDS"`     | `:gateway_shards`  | `:gateway_shards`  |
| `"REMEDY_MIN_WORKERS"`        | `:min_workers`     | `:min_workers`     |
| `"REMEDY_MAX_WORKERS"`        | `:max_workers`     | `:max_workers`     |

> #### Warning {: .warning}
>
> if Remedy is being started with `embedded: true` the `:token` can be provided to `start_link/2`. If `embedded: false` and no `:token` is provided, the application will not start.

To configure your application using a `.env` file place it in the root of your application. It will look something like this:
```
export REMEDY_GATEWAY_INTENTS="all"
export REMEDY_MIN_WORKERS="2"
export REMEDY_MAX_WORKERS="2"
export REMEDY_GATEWAY_SHARDS="1"
```


- `:token`
Your bots token, available from your
[Application Dashboard](https://discord.com/developers/applications)
- `:shards`
Number of shards to use.
- `:intents`
See `Remedy.Gateway.Intents` for more information
- `:min_workers`
The minimum number of HTTP2 connections to keep open. Defaults to 1, cannot be zero.
- `:max_workers`
The maximum number of HTTP2 connections to keep open. Defaults to 10, cannot be zero.

### Environment Variables
It is recommended to use environment variables to store sensitive configuration. So that they are not exposed if you should upload your project to GitHub etc. If a token is uploded to a public repo, Discord will notice and invalidate it.

## Connection Limits
Some hosting platforms will limit the number of connections you are allowed to keep active at any one time.
Each shard and HTTP2 worker will count for an individual connection. In addition to any other connections required for your application. Phoenix will establish 10 connections to the database by default. If you are using Heroku free tier (20 connection limit) you could run out of connections for users visiting your web application. In those cases you should consider limiting the number of shards and HTTP2 workers.
We recommend using [Gigalixir](https://www.gigalixir.com/) or [Fly.io](https://fly.io/) for your hosting platform. The gigalixir free tier has unlimited connections and will allow your bot to run automatically configured shards without issues.
