defmodule Remedy.Gateway.Dispatch.ChannelUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{id: id} = payload, socket}) do
    {event, Cache.update_channel(id, payload), socket}
  end
end
