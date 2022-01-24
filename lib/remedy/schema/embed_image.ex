defmodule Remedy.Schema.EmbedImage do
  @moduledoc """
  Embed Image Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          url: String.t(),
          proxy_url: String.t(),
          height: integer(),
          width: integer()
        }

  @primary_key false
  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:url, :proxy_url, :height, :width])
    |> validate_required(:url)
  end
end
