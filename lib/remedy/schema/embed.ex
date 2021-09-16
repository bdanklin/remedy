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

defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          inline: boolean()
        }

  embedded_schema do
    field :name, :string, required: true
    field :value, :string, required: true
    field :inline
  end
end

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

  embedded_schema do
    field :name
    field :url
    field :icon_url
    field :proxy_icon_url
  end
end

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

defmodule Remedy.Schema.EmbedImage do
  @moduledoc """
  Discord Embed Image Object
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
