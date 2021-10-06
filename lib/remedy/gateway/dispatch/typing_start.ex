defmodule Remedy.Gateway.Dispatch.TypingStart do
  @moduledoc false
  alias Remedy.Schema.TypingStart

  def handle({event, payload, socket}) do
    {event, TypingStart.new(payload), socket}
  end
end
