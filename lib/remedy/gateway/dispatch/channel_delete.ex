defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  alias Remedy.Schema.Channel
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Channel.new()
     |> Cache.delete_channel(), socket}
  end
end
