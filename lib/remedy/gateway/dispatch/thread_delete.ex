defmodule Remedy.Gateway.Dispatch.ThreadDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    Cache.delete_channel(payload)

    {event, payload, socket}
  end
end
