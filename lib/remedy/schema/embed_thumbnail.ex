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