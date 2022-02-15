defmodule Remedy do
  ## FFMPEG
  # @ffmpeg_url "https://github.com/FFmpeg/FFmpeg/releases/download/:version/ffmpeg-3.0.tar.gz"
  # @ffmpeg_ver "n3.0"

  @moduledoc """
  This is the documentation for the Remedy library.

  ## Configuration

      config :remedy
        token: System.get_env("REMEDY_TOKEN")
        intents: 12,
        shards: :auto,


  Configuration can be provided as starting arguments or inside your config.exs file. The configurable terms are as follows.

  - `:token` (required)
  Your bots token, available from your [Application Dashboard](https://discord.com/developers/applications)

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

  ## FFmpeg


  """
  use Application
  require Logger
  alias Remedy.{Consumer, Dispatch, Gateway, Rest, Repo, Voice}

  @env Mix.env()
  @args [:token, :min_workers, :max_workers, :shards, :intents, :env]

  @doc false
  def start(_type, args) do
    with :ok <- check_token(),
         :ok <- check_shards(),
         :ok <- check_intents() do
      args = for key <- @args, into: [], do: {key, determine(args, key)}

      children = [
        {Rest, args},
        {Repo, args},
        {Consumer, args},
        {Dispatch, args},
        {Gateway, args},
        {Voice, args}
      ]

      Supervisor.start_link(children, strategy: :one_for_one)
    end
  end

  defp determine(args, key) do
    case Keyword.get(args, key, :from_config) do
      :from_config -> apply(__MODULE__, key, [])
      val -> val
    end
  end

  @doc false
  def env, do: @env

  @doc "Retreive the bot token."
  @spec token :: any
  def token, do: System.get_env("REMEDY_BOT_TOKEN") || Application.get_env(:remedy, :token, false)

  @spec check_token :: :ok
  @dialyzer {:no_match, {:check_token, 1}}
  defp check_token, do: token() |> check_token()
  defp check_token(<<_::192, 46, _::48, 46, _::216>>), do: :ok
  defp check_token(false), do: raise("INVALID TOKEN CONFIGURATION")
  defp check_token(_invalid), do: raise("INVALID TOKEN CONFIGURATION")

  @doc "Retreive the configured shard count"
  @dialyzer {:no_match, {:shards, 1}}
  @spec shards :: integer()
  def shards, do: shards(@env)
  defp shards(:dev), do: System.get_env("REMEDY_GATEWAY_SHARDS") |> shards()
  defp shards(:prod), do: Application.get_env(:remedy, :shards, :auto) |> shards()
  defp shards("auto"), do: shards(:auto)
  defp shards(string) when is_binary(string), do: String.to_integer(string) |> shards()
  defp shards(config) when config in [nil, :auto], do: :auto
  defp shards(shards) when is_integer(shards), do: shards
  defp shards(_invalid), do: raise("INVALID SHARD CONFIGURATION")

  @spec check_shards :: :ok
  @dialyzer {:no_match, {:check_shards, 1}}
  defp check_shards, do: check_shards(@env)
  defp check_shards(:dev), do: System.get_env("REMEDY_GATEWAY_SHARDS") |> check_shards()
  defp check_shards(:prod), do: Application.get_env(:remedy, :shards) |> check_shards()
  defp check_shards("auto"), do: :ok
  defp check_shards(:auto), do: :ok
  defp check_shards(nil), do: Logger.warn("SHARDS NOT CONFIGURED, USING FALLBACK: :auto")
  defp check_shards(shards) when is_integer(shards), do: Logger.warn("USING CONFIGURED SHARDS: #{shards}")
  defp check_shards(_invalid), do: Logger.warn("INVALID SHARD CONFIGURATION, USING FALLBACK: :auto")

  alias Remedy.Gateway.Intents
  @doc "Retreive the configured gateway intents."
  @dialyzer {:no_match, {:intents, 1}}
  @spec intents :: integer()
  def intents, do: intents(@env)
  defp intents(:dev), do: intents(System.get_env("REMEDY_GATEWAY_INTENTS"))
  defp intents(:prod), do: intents(Application.get_env(:remedy, :gateway_intents, nil))
  defp intents(:error), do: default_intents()
  defp intents(nil), do: default_intents()
  defp intents("auto"), do: default_intents()
  defp intents(:auto), do: default_intents()
  defp intents(false), do: default_intents()
  defp intents({:ok, intents}), do: intents
  defp intents(intents), do: intents |> Intents.cast() |> intents()

  @spec check_intents :: :ok
  @dialyzer {:no_match, {:check_intents, 1}}
  defp check_intents, do: check_intents(@env)
  defp check_intents(:dev), do: check_intents(System.get_env("REMEDY_GATEWAY_INTENTS"))
  defp check_intents(:prod), do: check_intents(Application.get_env(:remedy, :gateway_intents, false))
  defp check_intents(false), do: Logger.warn("INTENTS NOT CONFIGURED, USING FALLBACK: :auto")
  defp check_intents(:error), do: Logger.warn("INVALID INTENTS CONFIGURATION, USING FALLBACK: :auto")
  defp check_intents("auto"), do: :ok
  defp check_intents(:auto), do: :ok
  defp check_intents({:ok, _intents}), do: :ok
  defp check_intents(intents), do: Intents.cast(intents) |> check_intents()

  @doc "Retreive the configured minimum HTTP worker count."
  @spec min_workers :: integer()
  def min_workers do
    (System.get_env("REMEDY_MIN_WORKERS") ||
       Application.get_env(:remedy, :min_workers, 10))
    |> String.to_integer()
  end

  @doc "Retreive the configured max HTTP worker count."
  @spec max_workers :: integer()
  def max_workers do
    (System.get_env("REMEDY_MAX_WORKERS") ||
       Application.get_env(:remedy, :max_workers, 10))
    |> String.to_integer()
  end

  @doc "Retreive the current system architecture."
  @spec system_architecture :: binary
  def system_architecture,
    do: "#{:erlang.system_info(:system_architecture)}"

  defp default_intents do
    [
      :GUILDS,
      :GUILD_MEMBERS,
      :GUILD_BANS,
      :GUILD_EMOJIS_AND_STICKERS,
      :GUILD_INTEGRATIONS,
      :GUILD_WEBHOOKS,
      :GUILD_INVITES,
      :GUILD_VOICE_STATES,
      :GUILD_PRESENCES,
      :GUILD_MESSAGES,
      :GUILD_MESSAGE_REACTIONS,
      :GUILD_MESSAGE_TYPING,
      :DIRECT_MESSAGES,
      :DIRECT_MESSAGE_REACTIONS,
      :DIRECT_MESSAGE_TYPING,
      :GUILD_SCHEDULED_EVENTS
    ]
    |> Intents.to_integer()
  end
end
