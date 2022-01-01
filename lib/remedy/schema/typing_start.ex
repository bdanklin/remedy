defmodule Remedy.Schema.TypingStart do
  use Remedy.Schema

  @moduledoc """
  Typing Start Event
  """

  @type t :: %__MODULE__{
          channel_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          user_id: Snowflake.t(),
          timestamp: ISO8601.t(),
          member: Member.t()
        }

  @primary_key false
  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :user_id, Snowflake
    field :timestamp, ISO8601
    embeds_one :member, Member
  end

  @doc false
  def form(attrs), do: changeset(attrs) |> apply_changes()

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:channel_id, :guild_id, :user_id, :timestamp])
    |> validate_required([:channel_id, :user_id, :timestamp])
    |> cast_embed(:member)
  end
end
