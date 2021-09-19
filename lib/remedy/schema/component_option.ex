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
end
