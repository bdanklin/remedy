defmodule Remedy.Schema.InteractionDataOption do
  @moduledoc """
  Interaction Data Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: integer(),
          value: String.t(),
          options: [__MODULE__.t()]
        }

  embedded_schema do
    field :name, :string
    field :type, :integer
    field :value, :string
    embeds_many :options, __MODULE__
  end
end
