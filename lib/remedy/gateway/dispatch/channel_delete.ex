defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{id: id}, socket}) do
    {event, Cache.delete_channel(id), socket}
  end
end
