defmodule Remedy.Gateway.Dispatch.ChannelUpdate do
  @moduledoc """
  Channel Update Event.

  ## Payload

  - `%Remedy.Schema.Channel{}`

  """
  alias Remedy.{Cache, Util}

  def handle({event, %{id: id} = payload, socket}) do
    case Cache.update_channel(id, payload) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, _changeset} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
