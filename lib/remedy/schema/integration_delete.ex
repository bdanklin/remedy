defmodule Remedy.Schema.IntegrationDelete do
  @moduledoc """
  Integration Delete Gateway Event
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          guild_id: Snowflake.t(),
          application_id: Snowflake.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :guild_id, Snowflake
    field :application_id, Snowflake
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
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

  @doc false
  def validate(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
