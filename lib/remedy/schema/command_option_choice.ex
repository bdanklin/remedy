defmodule Remedy.Schema.CommandOptionChoice do
  @moduledoc """
  Command Option Choice Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t()
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :value])
  end
end
