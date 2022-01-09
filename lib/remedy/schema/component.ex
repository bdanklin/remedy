defmodule Remedy.Schema.Component do
  @moduledoc """
  Component Object
  """
  use Remedy.Schema

  embedded_schema do
    field :type, ComponentType
    field :custom_id, :string
    field :disabled, :boolean
    field :style, ButtonStyle
    field :label, :string
    field :url, :string
    field :placeholder, :string
    field :min_values, :integer
    field :max_values, :integer
    embeds_one :emoji, Emoji
    embeds_many :options, ComponentOption
    embeds_many :components, Component
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
