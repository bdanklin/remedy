defmodule Remedy.Gateway.Dispatch.InviteDelete do
  @moduledoc """
  Struct representing an Invite Delete event
  """
  alias Remedy.Schema.{Channel, Guild}
  use Remedy.Schema

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :code, :string
  end

  @typedoc """
  Channel id of the channel this invite is for.
  """
  @type channel_id :: Channel.id()

  @typedoc """
  Guild id of the guild this invite is for.
  """
  @type guild_id :: Guild.id() | nil

  @typedoc """
  The unique invite code.
  """
  @type code :: String.t()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          code: code
        }

  def handle({event, payload, socket}) do
    {event, payload |> new(), socket}
  end
end
