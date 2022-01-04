defmodule Remedy.Schema.ActivitySecrets do
  @moduledoc """
  Activity Secrets Object
  """
  use Remedy.Schema

  embedded_schema do
    field :join, :string
    field :spectate, :string
    field :match, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:join, :spectate, :match])
  end
end
