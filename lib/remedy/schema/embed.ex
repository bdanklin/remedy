defmodule Remedy.Schema.Embed do
  @moduledoc """
  Discord Embed Object
  """
  use Remedy.Schema
  alias Remedy.ISO8601

  @type t :: %__MODULE__{
          title: String.t(),
          type: String.t(),
          description: String.t(),
          url: String.t(),
          timestamp: ISO8601.t(),
          color: integer(),
          fields: [EmbedField.t()],
          author: EmbedAuthor.t(),
          footer: EmbedFooter.t(),
          image: EmbedImage.t(),
          provider: EmbedProvider.t(),
          thumbnail: EmbedThumbnail.t(),
          video: EmbedVideo.t()
        }

  @derive {Jason.Encoder, []}
  @primary_key false
  embedded_schema do
    field :title, :string
    field :type, :string
    field :description, :string
    field :url, :string
    field :timestamp, ISO8601
    field :color, Colour

    embeds_many :fields, EmbedField
    embeds_one :author, EmbedAuthor
    embeds_one :footer, EmbedFooter
    embeds_one :image, EmbedImage
    embeds_one :provider, EmbedProvider
    embeds_one :thumbnail, EmbedThumbnail
    embeds_one :video, EmbedVideo
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:title, :type, :description, :url, :timestamp, :color])
    |> validate_required(:description)
    |> validate_exclusion(:description, [""])
    |> validate_length(:title, max: 256)
    |> validate_length(:description, max: 4096)
    |> cast_embed(:fields)
    |> cast_embed(:author)
    |> cast_embed(:footer)
    |> cast_embed(:image)
    |> cast_embed(:provider)
    |> cast_embed(:thumbnail)
    |> cast_embed(:video)
  end
end
