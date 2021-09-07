defmodule Remedy.Gateway.Commands do
  @moduledoc false
  alias Remedy.Gateway.Commands.{
    Heartbeat,
    Identify,
    RequestGuildMembers,
    Resume,
    UpdatePresence,
    UpdateVoiceState
  }

  def heartbeat(state), do: Heartbeat.payload(state)
  def identify(state), do: Identify.payload(state)
  def request_guild_members(state), do: RequestGuildMembers.payload(state)
  def resume(state), do: Resume.payload(state)
  def update_presence(state), do: UpdatePresence.payload(state)
  def update_voice_state(state), do: UpdateVoiceState.payload(state)
end
