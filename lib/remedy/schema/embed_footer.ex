defmodule Remedy.Schema.EmbedFooter do
  @moduledoc """
  Discord Embed Footer Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          text: String.t(),
          icon_url: String.t(),
          proxy_icon_url: String.t()
        }

  embedded_schema do
    field :text, :string, required: true
    field :icon_url
    field :proxy_icon_url
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
