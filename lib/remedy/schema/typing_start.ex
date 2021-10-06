defmodule Remedy.Schema.TypingStart do
  @moduledoc false
  use Remedy.Schema

  @type channel_id :: Snowflake.t()
  @type guild_id :: Snowflake.t()
  @type user_id :: Snowflake.t()
  @type timestamp :: ISO8601.t()
  @type member :: Member.t()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          user_id: user_id,
          timestamp: timestamp,
          member: member
        }

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :user_id, Snowflake
    field :timestamp, :integer
    embeds_one :member, Member
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
