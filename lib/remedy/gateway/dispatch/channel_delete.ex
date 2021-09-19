defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, %{id: id} = payload, socket}) do
    Cache.delete_channel(id)

    {event,
     payload
     |> Channel.new(), socket}
  end
end
