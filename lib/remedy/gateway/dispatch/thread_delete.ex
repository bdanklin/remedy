defmodule Remedy.Gateway.Dispatch.ThreadDelete do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Channel{}.

  """
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.delete_channel(payload)

    {event, Channel.new(payload), socket}
  end
end
