defmodule Remedy.Gateway.Dispatch.ThreadCreate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Channel{}.

  """
  alias Remedy.Cache
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    Cache.create_channel(payload)

    {event, Channel.new(payload), socket}
  end
end
