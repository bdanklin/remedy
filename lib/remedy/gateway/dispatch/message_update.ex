defmodule Remedy.Gateway.Dispatch.MessageUpdate do
  @moduledoc """
  Dispatched when a new message channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Message{}.

  """
  alias Remedy.Cache
  alias Remedy.Schema.Message

  def handle({event, payload, socket}) do
    Cache.update_message(payload)
    {event, Message.new(payload), socket}
  end
end
