defmodule Remedy.Gateway.Dispatch do
  alias Remedy.Gateway.WSState
  @moduledoc false

  # Dispatch is the mechanism for processing events en route to the consumer.
  #
  # Any secondary processing should occur within the dispatch modules.
  # This covers operations such as cacheing. Data validation.

  defmacro __using__(_env) do
    alias Remedy.Gateway.WSState
  end

  @type payload :: any()
  @type socket :: WSState.t()
  @type event :: atom()
  @callback handle({event, payload, socket}) :: {event, payload, socket}

  @dispatch_events [
    # Channel Cache
    :CHANNEL_CREATE,
    :CHANNEL_UPDATE,
    :CHANNEL_PINTS_UPDATE,
    :CHANNEL_DELETE,
    # Ban Cache
    :GUILD_BAN_ADD,
    :GUILD_BAN_REMOVE,
    # Guild Cache
    :GUILD_CREATE,
    :GUILD_DELETE,
    :GUILD_UPDATE,
    :GUILD_INTEGRATIONS_UPDATE,
    # Emojis Cache
    :GUILD_EMOJIS_UPDATE,
    # Member Cache
    :GUILD_MEMBER_REMOVE,
    :GUILD_MEMBER_UPDATE,
    :GUILD_MEMBERS_CHUNK,
    :GUILD_MEMBER_ADD,
    # Role Cache
    :GUILD_ROLE_CREATE,
    :GUILD_ROLE_DELETE,
    :GUILD_ROLE_UPDATE,
    :GUILD_STICKERS_UPDATE,
    # Integration Cache
    :INTEGRATION_CREATE,
    :INTEGRATION_DELETE,
    :INTEGRATION_UPDATE,
    # Interaction Cache
    :INTERACTION_CREATE,
    # Invite Cache
    :INVITE_CREATE,
    :INVITE_DELETE,
    # Message Cache
    :MESSAGE_CREATE,
    :MESSAGE_DELETE_BULK,
    :MESSAGE_DELETE,
    :MESSAGE_UPDATE,
    # Reaction Cache
    :MESSAGE_REACTION_ADD,
    :MESSAGE_REACTION_REMOVE_ALL,
    :MESSAGE_REACTION_REMOVE_EMOJI,
    :MESSAGE_REACTION_REMOVE,
    # Presence Cache
    :PRESENCE_UPDATE,
    :READY,
    :RESUMED,
    :SPEAKING_UPDATE,
    # Stage Cache
    :STAGE_INSTANCE_CREATE,
    :STAGE_INSTANCE_DELETE,
    :STAGE_INSTANCE_UPDATE,
    # Thread Cache
    :THREAD_CREATE,
    :THREAD_DELETE,
    :THREAD_UPDATE,
    :THREAD_LIST_SYNC,
    # Thread Member Cache
    :THREAD_MEMBER_UPDATE,
    :THREAD_MEMBERS_UPDATE,
    # Typing Activity
    :TYPING_START,
    # User Cache
    :USER_UPDATE,
    :VOICE_SERVER_UPDATE,
    :VOICE_STATE_UPDATE,
    :WEBHOOKS_UPDATE
  ]

  require Logger

  def handle({event, payload, socket}) do
    payload = payload |> Morphix.atomorphiform!()

    if Application.get_env(:remedy, :log_everything, true),
      do: Logger.debug("#{inspect(event)}, #{inspect(payload, pretty: true, limit: :infinity)}")

    case event in @dispatch_events do
      true ->
        mod_from_dispatch(event).handle({event, payload, socket})

      false ->
        Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{event}, #{inspect(payload)}")
        {event, payload, socket}
    end
  end

  defp mod_from_dispatch(k) when k in @dispatch_events do
    mod = to_string(k) |> String.downcase() |> Recase.to_pascal() |> List.wrap() |> Module.concat()

    Module.concat([Remedy.Gateway.Dispatch, mod])
  end
end
