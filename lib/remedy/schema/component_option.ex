defmodule Remedy.Schema.ComponentOption do
  @moduledoc """
  Component Options
  """
  use Remedy.Schema
  @type label :: Component.label()
  @type value :: String.t()
  @type description :: Component.description()
  @type emoji :: Component.emoji()
  @type default :: Component.default()

  @type t :: %__MODULE__{
          default: default,
          description: description,
          emoji: emoji,
          label: label,
          value: value
        }
  embedded_schema do
    field :label, :string
    field :value, :string
    field :description, :string
    field :default, :boolean
    embeds_one :emoji, Emoji
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
