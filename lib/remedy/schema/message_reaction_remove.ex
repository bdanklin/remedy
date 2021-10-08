defmodule Remedy.Schema.MessageReactionRemove do
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

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(any), do: any

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
