defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          inline: boolean()
        }

  embedded_schema do
    field :name, :string, required: true
    field :value, :string, required: true
    field :inline
  end
end
