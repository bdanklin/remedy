defmodule Remedy.Schema.CommandOptionChoice do
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
