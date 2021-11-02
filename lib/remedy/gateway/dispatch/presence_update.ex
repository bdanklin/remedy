defmodule Remedy.Gateway.Dispatch.PresenceUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{user: user} = payload, socket}) do
    Cache.update_user(user)
    Cache.update_presence(payload)

    {event, payload, socket}
  end
end
