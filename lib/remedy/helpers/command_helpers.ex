defmodule Remedy.CommandHelpers do
  @moduledoc false
  alias Remedy.Gateway.Commands.{
    Heartbeat,
    Identify,
    RequestGuildMembers,
    Resume,
    UpdatePresence,
    UpdateVoiceState
  }

  def heartbeat(socket, opts \\ []), do: Heartbeat.payload(socket, opts)
  def identify(socket, opts \\ []), do: Identify.payload(socket, opts)
  def request_guild_members(socket, opts \\ []), do: RequestGuildMembers.payload(socket, opts)
  def resume(socket, opts \\ []), do: Resume.payload(socket, opts)
  def update_presence(socket, opts \\ []), do: UpdatePresence.payload(socket, opts)
  def update_voice_state(socket, opts \\ []), do: UpdateVoiceState.payload(socket, opts)
end
