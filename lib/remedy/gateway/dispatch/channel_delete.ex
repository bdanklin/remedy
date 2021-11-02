defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  @moduledoc """
  Channel Delete Event.

    ## Payload

  - `%Remedy.Schema.Channel{}`
  """
  alias Remedy.{Cache, Util}

  def handle({event, %{id: id}, socket}) do
    case Cache.delete_channel(id) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, %Ecto.Changeset{}} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
