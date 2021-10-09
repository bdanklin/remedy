defmodule Remedy.Schema.ThreadMember do
  @moduledoc """
  Thread Member Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          join_timestamp: ISO8601.t(),
          flags: integer()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :user_id, Snowflake
    field :join_timestamp, ISO8601
    field :flags, :integer
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
