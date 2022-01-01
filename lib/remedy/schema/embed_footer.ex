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

  @primary_key false
  embedded_schema do
    field :text, :string
    field :icon_url, :string
    field :proxy_icon_url, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:text, :icon_url, :proxy_icon_url])
    |> validate_required(:text)
  end
end
