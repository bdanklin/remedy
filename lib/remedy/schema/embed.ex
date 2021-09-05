defmodule Remedy.Schema.Embed do
  @moduledoc false
  use Remedy.Schema, :model
  alias Embed.{Field, Author, Footer, Provider, Thumbnail, Video}

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "embeds" do
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

defmodule Remedy.Schema.Embed.Field do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :name, :string, required: true
    field :value, :string, required: true
    field :inline
  end
end

defmodule Remedy.Schema.Embed.Author do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :name
    field :url
    field :icon_url
    field :proxy_icon_url
  end
end

defmodule Remedy.Schema.Embed.Footer do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :text, :string, required: true
    field :icon_url
    field :proxy_icon_url
  end
end

defmodule Remedy.Schema.Embed.Image do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end
end

defmodule Remedy.Schema.Embed.Provider do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :provider, :string
    field :url, :string
  end
end

defmodule Remedy.Schema.Embed.Thumbnail do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end
end
