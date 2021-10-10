defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{channel_id: id, last_pin_timestamp: last_pin_timestamp}, socket}) do
    attrs = %{last_pin_timestamp: last_pin_timestamp}

    {event, Cache.update_channel(id, attrs), socket}
  end
end
