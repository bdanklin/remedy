defmodule Remedy.Schema.Reaction do
  @doc """
  Message Reaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          count: integer(),
          me: boolean(),
          emoji: Emoji.t()
        }

  @primary_key false
  embedded_schema do
    field :count, :integer
    field :me, :boolean
    embeds_one :emoji, Emoji
  end
end
