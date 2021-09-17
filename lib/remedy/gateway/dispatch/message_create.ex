defmodule Remedy.Gateway.Dispatch.MessageCreate do
  @moduledoc false
  alias Remedy.Schema.Message

  def handle({event, payload, socket}) do
    {event, payload |> Message.new(), socket}
  end
end
