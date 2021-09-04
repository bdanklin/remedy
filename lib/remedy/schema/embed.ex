defmodule Remedy.Schema.Embed do
  @moduledoc false
  use Remedy.Schema, :model

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "embeds" do
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

defmodule Remedy.Schema.Embed.Author do
  use Remedy.Schema, :model

  embedded_schema do
    field :name
    field :url
    field :icon_url
    field :proxy_icon_url
  end
end

defmodule Remedy.Schema.Embed.Field do
  use Remedy.Schema, :model

  embedded_schema do
    field :name, :string, required: true
    field :value, :string, required: true
    field :inline
  end
end

defmodule Remedy.Schema.Embed.Footer do
  use Remedy.Schema, :model

  embedded_schema do
    field :text, :string, required: true
    field :icon_url
    field :proxy_icon_url
  end
end
