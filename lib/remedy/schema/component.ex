defmodule Remedy.Schema.Component do
  @moduledoc """
  Component Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: ComponentType.t(),
          custom_id: String.t(),
          disabled: boolean(),
          style: ButtonStyle.t(),
          label: String.t(),
          url: URL.t(),
          placeholder: String.t(),
          min_values: integer(),
          max_values: integer(),
          emoji: Emoji.t(),
          options: [ComponentOption.t()],
          components: [__MODULE__.t()]
        }

  embedded_schema do
    field :type, ComponentType
    field :custom_id, :string
    field :disabled, :boolean
    field :style, ButtonStyle
    field :label, :string
    field :url, URL
    field :placeholder, :string
    field :min_values, :integer
    field :max_values, :integer
    embeds_one :emoji, Emoji
    embeds_many :options, ComponentOption
    embeds_many :components, __MODULE__
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
