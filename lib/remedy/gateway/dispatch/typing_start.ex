defmodule Remedy.Gateway.Dispatch.TypingStart do
  @moduledoc false
  use Remedy.Schema

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :user_id, Snowflake
    field :timestamp, :integer
    embeds_one :member, Member
  end

  def handle({event, payload, socket}) do
    {event, new(payload), socket}
  end
end
