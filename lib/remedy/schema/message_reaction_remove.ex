defmodule Remedy.Schema.MessageReactionRemove do
  @moduledoc """
  Message Reaction Remove Event
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          message_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          member: Member.t(),
          emoji: Emoji.t()
        }

  embedded_schema do
    field :user_id, Snowflake
    field :channel_id, Snowflake
    field :message_id, Snowflake
    field :guild_id, Snowflake
    embeds_one :member, Member
    embeds_one :emoji, Emoji
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(any), do: any
  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
