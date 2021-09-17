defmodule Remedy.Gateway.Dispatch.MessageDeleteBulk do
  @moduledoc """
  Struct representing a Message Delete Bulk event
  """

  use Remedy.Schema
  alias Remedy.Schema.Message
  alias Remedy.Cache

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          ids: ids
        }

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :ids, {:array, :integer}, virtual: true
  end

  @typedoc "Channel id of the deleted message"
  @type channel_id :: Channel.id()

  @typedoc """
  Guild id of the deleted message

  `nil` if a non-guild message was deleted.
  """
  @type guild_id :: Guild.id() | nil

  @typedoc "Ids of the deleted messages"
  @type ids :: [Message.id(), ...]

  def handle({event, %{ids: ids} = payload, socket}) do
    for message <- ids do
      Cache.delete_message(message)
    end

    {event, payload |> new(), socket}
  end
end
