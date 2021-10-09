defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  alias Remedy.Schema.ChannelPinsUpdate
  alias Remedy.Cache

  def handle(
        {event,
         %{
           channel_id: id,
           guild_id: guild_id,
           last_pin_timestamp: last_pin_timestamp
         } = payload, socket}
      ) do
    attrs = %{guild_id: guild_id, last_pin_timestamp: last_pin_timestamp}
    Cache.update_channel(id, attrs)

    {event,
     payload
     |> ChannelPinsUpdate.new(), socket}
  end
end
