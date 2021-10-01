defmodule Remedy.Schema.Embed do
  @moduledoc """
  Discord Embed Object
  """
  use Remedy.Schema

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

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
