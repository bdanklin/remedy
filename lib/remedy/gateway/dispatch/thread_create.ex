defmodule Remedy.Gateway.Dispatch.ThreadCreate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Channel.new()
     |> Cache.create_channel(), socket}
  end
end
