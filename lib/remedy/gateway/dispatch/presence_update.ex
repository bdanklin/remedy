defmodule Remedy.Gateway.Dispatch.PresenceUpdate do
  @moduledoc false
  alias Remedy.Schema.PresenceUpdate
  alias Remedy.Cache

  def handle({event, %{client_status: client_status, status: status} = payload, socket}) do
    payload = %{payload | client_status: parse_client_status(client_status), status: to_string(status)}

    Cache.update_presence(payload)
    {event, PresenceUpdate.new(payload), socket}
  end

  defp parse_client_status(client_status) do
    for {k, v} <- client_status, into: %{} do
      {k, to_string(v)}
    end
  end
end
