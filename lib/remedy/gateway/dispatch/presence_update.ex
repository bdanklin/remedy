defmodule Remedy.Gateway.Dispatch.PresenceUpdate do
  @moduledoc false
  alias Remedy.Schema.PresenceUpdate

  def handle({event, payload, socket}) do
    {event, PresenceUpdate.new(payload), socket}
  end
end
