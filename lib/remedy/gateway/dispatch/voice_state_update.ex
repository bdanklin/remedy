defmodule Remedy.Gateway.Dispatch.VoiceStateUpdate do
  @moduledoc false

  alias Remedy.Schema.VoiceStateUpdate

  def handle({event, payload, socket}) do
    {event, VoiceStateUpdate.new(payload), socket}
  end
end
