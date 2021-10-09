defmodule Remedy.Schema.CommandOptionChoice do
  @moduledoc """
  Command Option Choice
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: any()
        }

  embedded_schema do
    field :name, :string
    field :value, :any, virtual: true
  end
end
