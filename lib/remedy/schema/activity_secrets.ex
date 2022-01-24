defmodule Remedy.Schema.ActivitySecrets do
  @moduledoc """
  Activity Secrets Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          join: String.t() | nil,
          spectate: String.t() | nil,
          match: String.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :join, :string
    field :spectate, :string
    field :match, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:join, :spectate, :match])
  end
end
