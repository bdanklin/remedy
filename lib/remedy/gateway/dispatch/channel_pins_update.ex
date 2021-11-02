defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc """
  Channel Pins Update

    ## Payload

  - `%Remedy.Schema.Channel{}`
  """
  alias Remedy.{Cache, Util}

  def handle({event, %{channel_id: id, last_pin_timestamp: last_pin_timestamp}, socket}) do
    case Cache.update_channel(id, %{last_pin_timestamp: last_pin_timestamp}) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, %Ecto.Changeset{}} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
