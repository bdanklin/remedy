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

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :description, :string
    field :banner_asset_id, Snowflake, virtual: true
    # field :sku_id	snowflake	id of the pack's SKU

    has_one :cover_sticker, Sticker
    has_many :stickers, Sticker
  end
end
