defmodule Remedy.Schema.EmbedAuthor do
  @moduledoc """
  Discord Embed Author Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          url: String.t(),
          icon_url: String.t(),
          proxy_icon_url: String.t()
        }

  @primary_key false
  embedded_schema do
    field :name
    field :url
    field :icon_url
    field :proxy_icon_url
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :url, :icon_url, :proxy_icon_url])
    |> validate_required(:name)
    |> validate_length(:name, max: 256)
  end
end
