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
    field :color, :integer

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

defmodule Remedy.Schema.EmbedAuthor do
  @moduledoc """
  Discord Embed Author Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{name: String.t(), url: String.t(), icon_url: String.t(), proxy_icon_url: String.t()}

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
  end
end

defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{name: String.t(), value: String.t(), inline: boolean()}

  @primary_key false
  embedded_schema do
    field :name
    field :value
    field :inline, :boolean, default: false
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :value, :inline])
    |> validate_required([:name, :value])
  end
end

defmodule Remedy.Schema.EmbedFooter do
  @moduledoc """
  Discord Embed Footer Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{text: String.t(), icon_url: String.t(), proxy_icon_url: String.t()}

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

defmodule Remedy.Schema.EmbedImage do
  @moduledoc """
  Discord Embed Image Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{url: String.t(), proxy_url: String.t(), height: integer(), width: integer()}

  @primary_key false
  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:url, :proxy_url, :height, :width])
    |> validate_required(:url)
  end
end

defmodule Remedy.Schema.EmbedProvider do
  @moduledoc """
  Discord Embed Provider Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{provider: String.t(), url: String.t()}

  @primary_key false
  embedded_schema do
    field :provider, :string
    field :url, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:provider, :url])
  end
end

defmodule Remedy.Schema.EmbedThumbnail do
  @moduledoc """
  Discord Embed Thumbnail Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{url: String.t(), proxy_url: String.t(), height: integer(), width: integer()}

  @primary_key false
  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:url, :proxy_url, :height, :width])
  end
end

defmodule Remedy.Schema.EmbedVideo do
  @moduledoc """
  Embed Video Object.
  """
  use Remedy.Schema

  @type t :: %__MODULE__{url: String.t(), proxy_url: String.t(), height: integer(), width: integer()}

  @primary_key false
  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:url, :proxy_url, :height, :width])
  end
end
