defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  use Remedy.Gateway.Dispatch
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.create_channel(payload)

    {event, Channel.new(payload), socket}
  end
end
