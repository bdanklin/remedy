defmodule Remedy.Schema.ActivityTimestamps do
  @moduledoc """
  Activity Timestamps Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          start: Timestamp.t() | nil,
          end: Timestamp.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :start, Timestamp
    field :end, Timestamp
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:start, :end])
  end
end
