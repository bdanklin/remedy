defmodule Remedy.Gateway.Dispatch.MessageDelete do
  @moduledoc false

  alias Remedy.Schema.Message

  def handle({event, payload, socket}) do
    {event, payload |> Message.new(), socket}
  end
end
