defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  use Remedy.Gateway.Dispatch
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.delete_channel(payload)

    {event,
     payload
     |> Channel.new(), socket}
  end
end
