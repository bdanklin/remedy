defmodule Remedy.Gateway.Dispatch.MessageDelete do
  @moduledoc false

  alias Remedy.Schema.Message

  @typedoc """
  Guild id of the deleted message

  `nil` if a non-guild message was deleted.
  """
  @type guild_id :: Guild.id() | nil

  def handle({event, payload, socket}) do
    {event, payload |> Message.new(), socket}
  end
end
