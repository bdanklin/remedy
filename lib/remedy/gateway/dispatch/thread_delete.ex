defmodule Remedy.Gateway.Dispatch.ThreadDelete do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.delete_channel(payload)

    {event, Channel.new(payload), socket}
  end
end
