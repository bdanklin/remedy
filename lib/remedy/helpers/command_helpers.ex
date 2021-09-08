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

  def heartbeat(state, opts \\ []), do: Heartbeat.payload(state, opts)
  def identify(state, opts \\ []), do: Identify.payload(state, opts)
  def request_guild_members(state, opts \\ []), do: RequestGuildMembers.payload(state, opts)
  def resume(state, opts \\ []), do: Resume.payload(state, opts)
  def update_presence(state, opts \\ []), do: UpdatePresence.payload(state, opts)
  def update_voice_state(state, opts \\ []), do: UpdateVoiceState.payload(state, opts)
end
