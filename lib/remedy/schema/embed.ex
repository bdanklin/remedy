defmodule Remedy.Schema.Embed do
  @moduledoc """
  Discord Embed Object
  """
  use Remedy.Schema
  alias Embed.{Author, Field, Footer, Provider, Thumbnail, Video}

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
          provider: Provider.t(),
          thumbnail: Thumbnail.t(),
          video: Video.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :title, :string
    field :type, :string
    field :description, :string
    field :url, :string
    field :timestamp, ISO8601
    field :color, :integer

    embeds_many :fields, Field
    embeds_one :author, Author
    embeds_one :footer, Footer
    embeds_one :image, Image
    embeds_one :provider, Provider
    embeds_one :thumbnail, Thumbnail
    embeds_one :video, Video
  end
end
