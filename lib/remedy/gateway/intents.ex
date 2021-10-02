defmodule Remedy.Gateway.Intents do
  @moduledoc false
  use Remedy.Schema
  use BattleStandard
  @primary_key false

  embedded_schema do
    field :GUILDS, :boolean, default: true
    field :GUILD_MEMBERS, :boolean, default: false
    field :GUILD_BANS, :boolean, default: true
    field :GUILD_EMOJIS, :boolean, default: true
    field :GUILD_INTEGRATIONS, :boolean, default: true
    field :GUILD_WEBHOOKS, :boolean, default: true
    field :GUILD_INVITES, :boolean, default: true
    field :GUILD_VOICE_STATES, :boolean, default: true
    field :GUILD_PRESENCES, :boolean, default: false
    field :GUILD_MESSAGES, :boolean, default: true
    field :GUILD_MESSAGE_REACTIONS, :boolean, default: true
    field :GUILD_MESSAGE_TYPING, :boolean, default: true
    field :DIRECT_MESSAGES, :boolean, default: true
    field :DIRECT_MESSAGE_REACTIONS, :boolean, default: true
    field :DIRECT_MESSAGE_TYPING, :boolean, default: true
  end

  @type t :: %__MODULE__{
          GUILDS: boolean(),
          GUILD_MEMBERS: boolean(),
          GUILD_BANS: boolean(),
          GUILD_EMOJIS: boolean(),
          GUILD_INTEGRATIONS: boolean(),
          GUILD_WEBHOOKS: boolean(),
          GUILD_INVITES: boolean(),
          GUILD_VOICE_STATES: boolean(),
          GUILD_PRESENCES: boolean(),
          GUILD_MESSAGES: boolean(),
          GUILD_MESSAGE_REACTIONS: boolean(),
          GUILD_MESSAGE_TYPING: boolean(),
          DIRECT_MESSAGES: boolean(),
          DIRECT_MESSAGE_REACTIONS: boolean(),
          DIRECT_MESSAGE_TYPING: boolean()
        }

  @flag_bits [
    GUILDS: 1 <<< 0,
    GUILD_MEMBERS: 1 <<< 1,
    GUILD_BANS: 1 <<< 2,
    GUILD_EMOJIS: 1 <<< 3,
    GUILD_INTEGRATIONS: 1 <<< 4,
    GUILD_WEBHOOKS: 1 <<< 5,
    GUILD_INVITES: 1 <<< 6,
    GUILD_VOICE_STATES: 1 <<< 7,
    GUILD_PRESENCES: 1 <<< 8,
    GUILD_MESSAGES: 1 <<< 9,
    GUILD_MESSAGE_REACTIONS: 1 <<< 10,
    GUILD_MESSAGE_TYPING: 1 <<< 11,
    DIRECT_MESSAGES: 1 <<< 12,
    DIRECT_MESSAGE_REACTIONS: 1 <<< 13,
    DIRECT_MESSAGE_TYPING: 1 <<< 14
  ]

  def get do
    Application.get_env(:remedy, :gateway_intents)
    |> resolve()
    |> to_integer()
  end

  defp resolve(:all) do
    %__MODULE__{
      GUILD_MEMBERS: true,
      GUILD_PRESENCES: true
    }
  end
end
