defmodule Remedy.Schema.Component do
  use Remedy.Schema, :model

  @primary_key false
  schema "components" do
    field :title, :string
    field :type, :string
    field :description, :string
    field :url, :string
    field :timestamp, ISO8601
    field :color, :integer
    embeds_one :footer, Embed.Footer
    embeds_one :image, Image
    embeds_one :thumbnail, Thumbnail
    embeds_one :video, Video
    embeds_one :provider, Provider
    embeds_one :author, Author
    embeds_many :fields, Field
  end
end