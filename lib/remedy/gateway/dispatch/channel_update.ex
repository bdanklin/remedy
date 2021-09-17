defmodule Remedy.Gateway.Dispatch.ChannelUpdate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    payload
    |> Channel.new()
    |> Cache.update_channel()

    {event, payload, socket}
  end
end
