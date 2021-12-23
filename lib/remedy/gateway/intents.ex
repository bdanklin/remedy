defmodule Remedy.Gateway.Intents do
  @moduledoc """

  When connecting to the gateway, the intents must be specified, which will determine which events are subscribed to. You can specify which intents should be subscribed to by setting your application configuration appropriately.

  ## Options

  - `:all` - All intents will be subscribed to.
    ```elixir
    config :remedy,
      gateway_intents: :all,
    ```

  - `value`  - `:integer` - The value of the intents to subscribe to.
    ```elixir
    config :remedy,
      gateway_intents: 14275,
  ```

  - `[:intent, :intent, ...]` - A list of intents to subscribe to, eg. `:GUILDS, :GUILD_MEMBERS, :GUILD_BANS`.
    ```elixir
    config :remedy,
      gateway_intents: [:GUILDS, :GUILD_MEMBERS, :GUILD_BANS],
  ```

  ## Intents

  The following intents and their associated events are shown below:

  #### GUILDS
  - `:GUILD_CREATE`
  - `:GUILD_UPDATE`
  - `:GUILD_DELETE`
  - `:GUILD_ROLE_CREATE`
  - `:GUILD_ROLE_UPDATE`
  - `:GUILD_ROLE_DELETE`
  - `:CHANNEL_CREATE`
  - `:CHANNEL_UPDATE`
  - `:CHANNEL_DELETE`
  - `:CHANNEL_PINS_UPDATE`
  - `:THREAD_CREATE`
  - `:THREAD_UPDATE`
  - `:THREAD_DELETE`
  - `:THREAD_LIST_SYNC`
  - `:THREAD_MEMBER_UPDATE`
  - `:THREAD_MEMBERS_UPDATE`
  - `:STAGE_INSTANCE_CREATE`
  - `:STAGE_INSTANCE_UPDATE`
  - `:STAGE_INSTANCE_DELETE`

  #### GUILD_MEMBERS
  - `:GUILD_MEMBER_ADD`
  - `:GUILD_MEMBER_UPDATE`
  - `:GUILD_MEMBER_REMOVE`
  - `:THREAD_MEMBERS_UPDATE`

  #### GUILD_BANS
  - `:GUILD_BAN_ADD`
  - `:GUILD_BAN_REMOVE`

  #### GUILD_EMOJIS_AND_STICKERS
  - `:GUILD_EMOJIS_UPDATE`
  - `:GUILD_STICKERS_UPDATE`

  #### GUILD_INTEGRATIONS
  - `:GUILD_INTEGRATIONS_UPDATE`
  - `:INTEGRATION_CREATE`
  - `:INTEGRATION_UPDATE`
  - `:INTEGRATION_DELETE`

  #### GUILD_WEBHOOKS
  - `:WEBHOOKS_UPDATE`

  #### GUILD_INVITES
  - `:INVITE_CREATE`
  - `:INVITE_DELETE`

  #### GUILD_VOICE_STATES
  - `:VOICE_STATE_UPDATE`

  #### GUILD_PRESENCES
  - `:PRESENCE_UPDATE`

  #### GUILD_MESSAGES
  - `:MESSAGE_CREATE`
  - `:MESSAGE_UPDATE`
  - `:MESSAGE_DELETE`
  - `:MESSAGE_DELETE_BULK`

  #### GUILD_MESSAGE_REACTIONS
  - `:MESSAGE_REACTION_ADD`
  - `:MESSAGE_REACTION_REMOVE`
  - `:MESSAGE_REACTION_REMOVE_ALL`
  - `:MESSAGE_REACTION_REMOVE_EMOJI`

  #### GUILD_MESSAGE_TYPING
  - `:TYPING_START`

  #### DIRECT_MESSAGES
  - `:MESSAGE_CREATE`
  - `:MESSAGE_UPDATE`
  - `:MESSAGE_DELETE`
  - `:CHANNEL_PINS_UPDATE`

  #### DIRECT_MESSAGE_REACTIONS
  - `:MESSAGE_REACTION_ADD`
  - `:MESSAGE_REACTION_REMOVE`
  - `:MESSAGE_REACTION_REMOVE_ALL`
  - `:MESSAGE_REACTION_REMOVE_EMOJI`

  #### DIRECT_MESSAGE_TYPING
  - `:TYPING_START`

  #### GUILD_SCHEDULED_EVENTS
  - `:GUILD_SCHEDULED_EVENT_CREATE`
  - `:GUILD_SCHEDULED_EVENT_UPDATE`
  - `:GUILD_SCHEDULED_EVENT_DELETE`
  - `:GUILD_SCHEDULED_EVENT_USER_ADD`
  - `:GUILD_SCHEDULED_EVENT_USER_REMOVE`

  """

  use Remedy.Flag

  defstruct GUILDS: 1 <<< 0,
            GUILD_MEMBERS: 1 <<< 1,
            GUILD_BANS: 1 <<< 2,
            GUILD_EMOJIS_AND_STICKERS: 1 <<< 3,
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
            DIRECT_MESSAGE_TYPING: 1 <<< 14,
            GUILD_SCHEDULED_EVENTS: 1 <<< 15

  def get_config do
    Application.get_env(:remedy, :gateway_intents)
    |> resolve()
    |> to_integer()
  end

  defp resolve(:all) do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end

  defp resolve(value) when is_number(value) do
    value
  end

  defp resolve(list_of_intents) when is_list(list_of_intents) do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.to_list()
    |> Enum.filter(fn
      {k, _v} -> k in list_of_intents
    end)
    |> Enum.reduce([], fn
      {k, _v}, acc -> acc ++ [k]
    end)
  end
end
