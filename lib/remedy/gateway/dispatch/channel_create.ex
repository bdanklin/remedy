defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.create_channel(payload)

    {event, Channel.new(payload), socket}
  end
end
