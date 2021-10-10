defmodule Remedy.Gateway.Dispatch.TypingStart do
  @moduledoc """
  Typing Start Event Dispatch
  """
  def handle({event, payload, socket}) do
    payload = %{payload | payload: DateTime.from_unix!(payload.timestamp)}

    {event,
     payload
     |> new(), socket}
  end

  use Remedy.Schema

  @type t :: %__MODULE__{
          channel_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          user_id: Snowflake.t(),
          timestamp: ISO8601.t(),
          member: Member.t()
        }

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :user_id, Snowflake
    field :timestamp, ISO8601
    embeds_one :member, Member
  end

  def new(params) do
    %__MODULE__{}
    |> cast(params, [:channel_id, :guild_id, :user_id, :timestamp])
    |> apply_changes()
  end
end
