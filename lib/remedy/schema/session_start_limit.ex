defmodule Remedy.Schema.SessionStartLimit do
  @moduledoc """
  Session Start Limit Object
  """
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :total, :integer
    field :remaining, :integer
    field :reset_after, :integer
    field :max_concurrency, :integer
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:total, :remaining, :reset_after, :max_concurrency])
  end
end
