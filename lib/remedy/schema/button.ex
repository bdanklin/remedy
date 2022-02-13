defmodule Remedy.Schema.Button do
  @moduledoc """
  This module contains the Buttons
  """
  use Remedy.Schema

  @type t :: link | interaction

  @type link :: %__MODULE__{
          type: 2,
          style: Component.style(),
          custom_id: nil,
          label: Component.label() | nil,
          emoji: Component.emoji() | nil,
          custom_id: nil,
          url: Component.url(),
          disabled: Component.disabled()
        }

  @type interaction :: %__MODULE__{
          type: 2,
          style: Component.style(),
          label: Component.label(),
          emoji: Component.emoji() | nil,
          url: nil,
          custom_id: Component.custom_id(),
          disabled: Component.disabled()
        }

  embedded_schema do
    field :type, ComponentType, default: 2
    field :custom_id, :string
    field :disabled, :boolean
    field :style, ButtonStyle
    field :label, :string
    embeds_one :emoji, Emoji
    field :url, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:style, :custom_id, :label, :emoji, :url, :disabled])
    |> cast_embed(:emoji)
  end
end