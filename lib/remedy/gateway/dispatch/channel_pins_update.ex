defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  alias Remedy.Schema.ChannelPinsUpdate
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    %{
      id: payload.channel_id,
      guild_id: payload.guild_id,
      last_pin_timestamp: payload.last_pin_timestamp
    }
    |> Cache.update_channel()

    {event, ChannelPinsUpdate.new(payload), socket}
  end
end
