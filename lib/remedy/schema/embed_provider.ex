defmodule Remedy.Schema.EmbedProvider do
  @moduledoc """
  Discord Embed Provider Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          provider: String.t(),
          url: String.t()
        }

  @primary_key false
  embedded_schema do
    field :provider, :string
    field :url, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:provider, :url])
  end
end
