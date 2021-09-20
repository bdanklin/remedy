defmodule Remedy.Schema.EmbedProvider do
  @moduledoc """
  Discord Embed Provider Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          provider: String.t(),
          url: String.t()
        }

  embedded_schema do
    field :provider, :string
    field :url, :string
  end
end
