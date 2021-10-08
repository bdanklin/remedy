defmodule Remedy.Schema.ComponentOption do
  @moduledoc """
  Component Options
  """
  use Remedy.Schema
  @type label :: Component.label()
  @type value :: String.t()
  @type description :: String.t()
  @type emoji :: Component.emoji()
  @type default :: boolean

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
