defmodule Remedy.Schema.StickerPack do
  @moduledoc """
  Sticker Pack
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          banner_asset_id: Snowflake.t(),
          cover_sticker: Sticker.t(),
          stickers: [Sticker.t()]
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :description, :string
    field :banner_asset_id, Snowflake, virtual: true
    # field :sku_id	snowflake	id of the pack's SKU

    has_one :cover_sticker, Sticker
    has_many :stickers, Sticker
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
