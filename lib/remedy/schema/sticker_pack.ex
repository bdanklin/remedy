defmodule Remedy.Schema.StickerPack do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "sticker_packs" do
    field :name, :string
    field :description, :string
    field :banner_asset_id, Snowflake, virtual: true
    # field :sku_id	snowflake	id of the pack's SKU

    has_one :cover_sticker, Sticker
    has_many :stickers, Sticker
  end
end
