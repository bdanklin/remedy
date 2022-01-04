defmodule Remedy.Schema.ActivityButton do
  @moduledoc """
  Activity Button Schema
  """
  use Remedy.Schema

  embedded_schema do
    field :label, :string
    field :url, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:label, :url])
  end
end
