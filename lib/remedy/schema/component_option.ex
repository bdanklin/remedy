defmodule Remedy.Schema.ComponentOption do
  @moduledoc """
  Component Options
  """
  use Remedy.Schema

  embedded_schema do
    field :label, :string
    field :value, :string
    field :description, :string
    field :default, :boolean
    embeds_one :emoji, Emoji
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
