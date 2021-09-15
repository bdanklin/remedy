defmodule Remedy.Gateway.Dispatch.ChannelUpdate do
  use Remedy.Gateway.Dispatch

  def handle({event, payload, socket}) do
    Cache.update_channel(payload)

    {event, payload, socket}
  end
end
