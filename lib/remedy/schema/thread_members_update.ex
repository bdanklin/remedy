defmodule Remedy.Schema.ThreadMembersUpdate do
  @moduledoc """
  Thread Members Update
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake,
          member_count: integer(),
          removed_members: [Snowflake],
          guild_id: Snowflake,
          added_members: Snowflake
        }

  @primary_key false
  embedded_schema do
    field :id, Snowflake
    field :member_count, :integer
    field :removed_members, {:array, Snowflake}
    field :guild_id, Snowflake
    embeds_many :added_members, ThreadMember
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

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
