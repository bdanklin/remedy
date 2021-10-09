defmodule Remedy.Gateway.Dispatch.ChannelUpdate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, %{id: id} = payload, socket}) do
    {event,
     id
     |> Cache.update_channel(payload), socket}
  end
end
