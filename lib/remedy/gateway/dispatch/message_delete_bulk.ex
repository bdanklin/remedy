defmodule Remedy.Gateway.Dispatch.MessageDeleteBulk do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.{Message, MessageDeleteBulk}

  @typedoc "Channel id of the deleted message"
  @type channel_id :: Snowflake.t()

  @typedoc """
  Guild id of the deleted message

  `nil` if a non-guild message was deleted.
  """
  @type guild_id :: Snowflake.t() | nil

  @typedoc "Ids of the deleted messages"
  @type ids :: [Message.id(), ...]

  def handle({event, %{ids: ids} = payload, socket}) do
    for message <- ids do
      Cache.delete_message(message)
    end

    {event, payload |> MessageDeleteBulk.new(), socket}
  end
end
