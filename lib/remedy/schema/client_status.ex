defmodule Remedy.Schema.ClientStatus do
  @moduledoc """
  Client Status Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          desktop: String.t(),
          mobile: String.t(),
          web: String.t()
        }

  @primary_key false
  embedded_schema do
    field :desktop, Ecto.Enum, values: [:online, :idle, :dnd]
    field :mobile, Ecto.Enum, values: [:online, :idle, :dnd]
    field :web, Ecto.Enum, values: [:online, :idle, :dnd]
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:desktop, :mobile, :web])
  end
end
