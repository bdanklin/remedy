defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, %{id: id} = payload, socket}) do
    {event,
     payload
     |> Channel.new()
     |> Cache.delete_channel(), socket}
  end
end
