defmodule Remedy.Schema.ActivityButton do
  @moduledoc """
  Activity Button Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          label: String.t(),
          url: URL.t()
        }

  @primary_key false
  embedded_schema do
    field :label, :string
    field :url, URL
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:label, :url])
    |> validate_required([:label, :url])
  end
end
