defmodule Remedy.Gateway.Dispatch.MessageUpdate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Message

  def handle({event, payload, socket}) do
    Cache.upsert_message(payload)
    {event, Message.new(payload), socket}
  end
end
