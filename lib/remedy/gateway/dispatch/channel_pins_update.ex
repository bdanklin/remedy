defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{channel_id: id, last_pin_timestamp: last_pin_timestamp}, socket}) do
    %{id: id, last_pin_timestamp: last_pin_timestamp}
    |> Cache.update_channel()
    |> case do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, %Ecto.Changeset{}} ->
        :noop
    end
  end
end
