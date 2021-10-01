defmodule Remedy.Schema.UnavailableGuild do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          unavailable: true
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "guilds" do
    field :unavailable, :boolean
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(changeset) do
    changeset
  end

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
