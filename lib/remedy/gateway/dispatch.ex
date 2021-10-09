defmodule Remedy.Gateway.Dispatch do
  alias Remedy.Gateway.WSState
  @moduledoc false
  @type payload :: any()
  @type socket :: WSState.t()
  @type event :: atom()
  @callback handle({event, payload, socket}) :: {event, payload, socket}

  @dispatch_events [
    :CHANNEL_CREATE,
    :CHANNEL_DELETE,
    :CHANNEL_PINTS_UPDATE,
    :CHANNEL_UPDATE,
    :GUILD_BAN_ADD,
    :GUILD_BAN_REMOVE,
    :GUILD_CREATE,
    :GUILD_DELETE,
    :GUILD_EMOJIS_UPDATE,
    :GUILD_INTEGRATIONS_UPDATE,
    :GUILD_MEMBVER_ADD,
    :GUILD_MEMBER_REMOVE,
    :GUILD_MEMBER_UPDATE,
    :GUILD_MEMBERS_CHUNK,
    :GUILD_ROLE_CREATE,
    :GUILD_ROLE_DELETE,
    :GUILD_ROLE_UPDATE,
    :GUILD_STICKERS_UPDATE,
    :GUILD_UPDATE,
    :INTEGRATION_CREATE,
    :INTEGRATION_DELETE,
    :INTEGRATION_UPDATE,
    :INTERACTION_CREATE,
    :INVITE_CREATE,
    :INVITE_DELETE,
    :MESSAGE_CREATE,
    :MESSAGE_DELETE_BULK,
    :MESSAGE_DELETE,
    :MESSAGE_REACTION_ADD,
    :MESSAGE_REACTION_REMOVE_ALL,
    :MESSAGE_REACTION_REMOVE_EMOJI,
    :MESSAGE_REACTION_REMOVE,
    :MESSAGE_UPDATE,
    :PRESENCE_UPDATE,
    :READY,
    :RESUMED,
    :SPEAKING_UPDATE,
    :STAGE_INSTANCE_CREATE,
    :STAGE_INSTANCE_DELETE,
    :STAGE_INSTANCE_UPDATE,
    :THREAD_CREATE,
    :THREAD_DELETE,
    :THREAD_LIST_SYNC,
    :THREAD_MEMBER_UPDATE,
    :THREAD_MEMBERS_UPDATE,
    :THREAD_UPDATE,
    :TYPING_START,
    :USER_UPDATE,
    :VOICE_SERVER_UPDATE,
    :VOICE_STATE_UPDATE,
    :WEBHOOKS_UPDATE
  ]

  require Logger

  def handle({event, payload, socket} = dispatch) do
    if Application.get_env(:remedy, :log_everything, false),
      do: Logger.debug("#{inspect(event)}, #{inspect(payload)}")

    case event in @dispatch_events do
      true ->
        mod_from_dispatch(event).handle(dispatch)

      false ->
        Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{event}, #{inspect(payload)}")
        {event, payload, socket}
    end
  end

  defp mod_from_dispatch(k) do
    to_string(k) |> String.downcase() |> Recase.to_pascal() |> List.wrap() |> Module.concat()
  end
end
