defmodule Remedy.Schema.EmbedThumbnail do
  @moduledoc """
  Discord Embed Thumbnail Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          url: String.t(),
          proxy_url: String.t(),
          height: integer(),
          width: integer()
        }

  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end
end
