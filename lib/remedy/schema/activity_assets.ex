defmodule Remedy.Schema.ActivityAssets do
  @moduledoc """
  Activity Assets Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          large_image: String.t() | nil,
          small_image: String.t() | nil,
          large_text: String.t() | nil,
          small_text: String.t() | nil
        }

  embedded_schema do
    field :large_image, :string
    field :large_text, :string
    field :small_image, :string
    field :small_text, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:large_image, :large_text, :small_image, :small_text])
  end
end
