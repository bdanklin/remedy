defmodule Remedy do
  require Logger

  @moduledoc """
  This is the documentation for the Remedy library.
  """
  alias Remedy.Schema.{Channel, Emoji, Guild, Message, User, Role}
  alias Remedy.API
  alias Remedy.Gateway.Intents

  @doc """
  Retreive the configured shard count

  ## Examples

      iex> Remedy.shard_count
      3

  """
  @spec shards :: integer()
  def shards do
    config_shards = Application.get_env(:remedy, :shards, false)
    assigned_shards = API.get_gateway_bot!().shards

    case {config_shards, assigned_shards} do
      {false, assigned_shards} ->
        assigned_shards

      {config_shards, assigned_shards} when config_shards > assigned_shards ->
        Logger.warn("The configured shard count (#{config_shards}) > recommended shard count (#{assigned_shards})")

        config_shards

      {_, assigned_shards} ->
        assigned_shards
    end
  end

  @doc """
  Retreive the current system architecture.

  This is used to report to Discord the architecture of the system as required when establishing gateway connections.

  ## Examples

      iex> Remedy.get_system_architecture()
      "x86_64-redhat-linux-gnu"

  """
  @spec system_architecture :: binary
  def system_architecture do
    "#{to_string(:erlang.system_info(:system_architecture))}"
  end

  @doc """
  Retreive the bot token.
  """
  def token do
    token = Application.get_env(:remedy, :token, nil)

    case token do
      nil ->
        Logger.error("Token has not been configured. Please read the docs.")
        nil

      token ->
        token
    end
  end

  @default_intents [
    :GUILDS,
    :GUILD_MEMBERS,
    :GUILD_BANS,
    :GUILD_EMOJIS_AND_STICKERS,
    :GUILD_INTEGRATIONS,
    :GUILD_WEBHOOKS,
    :GUILD_INVITES,
    :GUILD_VOICE_STATES,
    :GUILD_MESSAGES,
    :GUILD_MESSAGE_REACTIONS,
    :GUILD_MESSAGE_TYPING,
    :DIRECT_MESSAGES,
    :DIRECT_MESSAGE_REACTIONS,
    :DIRECT_MESSAGE_TYPING,
    :GUILD_SCHEDULED_EVENTS
  ]

  @doc """
  Retreive the configured gateway intents for the bot.


  """
  ## Rather than setting the compile_env/3 default to @default_intents, it is
  ## set to false so an error can be logged to the user.
  @doc sin: "0.6.9"
  @dialyzer {:no_match, {:intents, 0}}
  @configured_intents Application.compile_env(:remedy, [:gateway_intents], false)
  @spec intents :: Intents.t()
  def intents do
    intents =
      @configured_intents
      |> case do
        false ->
          Logger.warn("Gateway Intents have not been configured, using default values. Please read the docs.")
          default_intents()

        intents ->
          intents
      end

    intents
    |> Intents.cast()
    |> case do
      :error ->
        Logger.warn("Gateway Intents are malformed or not configured, using default values. Please read the docs.")
        default_intents()

      {:ok, intents} ->
        intents
    end
  end

  defp default_intents, do: @default_intents |> Intents.to_integer()

  @doc """
  Format various types to a "mention"


  """
  def mention(type, format \\ nil)

  def mention(%User{id: user_id}, :nickname) do
    "<@#{user_id}>"
  end

  def mention(%User{id: user_id}, _format) do
    "<@!#{user_id}>"
  end

  def mention(%Channel{id: channel_id}, _format) do
    "<\# #{channel_id}>"
  end

  def mention(%Role{id: role_id}, _format) do
    "<@&#{role_id}>"
  end

  def mention(%Emoji{name: emoji_name, id: nil}, _format) do
    "#{emoji_name}"
  end

  def mention(%Emoji{id: emoji_id, animated: false}, _format) do
    "<:#{emoji_id}>"
  end

  def mention(%Emoji{id: emoji_id, name: emoji_name, animated: true}, _format) do
    "<a:#{emoji_name}:#{emoji_id}>"
  end

  def link(type, _format)

  def link(%Message{id: message_id, channel_id: channel_id, guild_id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}/#{channel_id}/#{message_id}>"
  end

  def link(%Channel{id: channel_id, guild_id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}/#{channel_id}>"
  end

  def link(%Guild{id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}>"
  end
end
