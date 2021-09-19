defmodule Remedy.Schema.EmbedFooter do
  @moduledoc """
  Discord Embed Footer Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          text: String.t(),
          icon_url: String.t(),
          proxy_icon_url: String.t()
        }

  embedded_schema do
    field :text, :string, required: true
    field :icon_url
    field :proxy_icon_url
  end
end
