defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          inline: boolean()
        }

  embedded_schema do
    field :name, :string, required: true
    field :value, :string, required: true
    field :inline
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
