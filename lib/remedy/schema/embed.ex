defmodule Remedy.Schema.Embed do
  @moduledoc """
  Discord Embed Object
  """
  use Remedy.Schema

  @type title :: String.t()
  @type type :: String.t()
  @type description :: String.t()
  @type url :: String.t()
  @type timestamp :: ISO8601.t()
  @type color :: integer()
  @type fields :: [EmbedField.t()]
  @type author :: EmbedAuthor.t()
  @type footer :: EmbedFooter.t()
  @type image :: EmbedImage.t()
  @type provider :: EmbedProvider.t()
  @type thumbnail :: EmbedThumbnail.t()
  @type video :: EmbedVideo.t()

  @type t :: %__MODULE__{
          title: title,
          type: type,
          description: description,
          url: url,
          timestamp: timestamp,
          color: color,
          fields: fields,
          author: author,
          footer: footer,
          image: image,
          provider: provider,
          thumbnail: thumbnail,
          video: video
        }

  @primary_key {:id, :id, autogenerate: false}
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

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
