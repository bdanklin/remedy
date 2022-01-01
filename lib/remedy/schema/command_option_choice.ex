defmodule Remedy.Schema.CommandOptionChoice do
  @moduledoc """
  Command Option Choice
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t() | :integer
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :value, :any, virtual: true
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :value])
  end
end
