defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    {event, Cache.create_channel(payload), socket}
  end
end
