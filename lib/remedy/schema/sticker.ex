defmodule Remedy.Schema.Sticker do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "stickers" do
    field :name, :string
    field :description, :string
    field :tags, :string
    #  field :asset, :string	Deprecated previously the sticker asset hash, now an empty string
    field :type, :integer
    field :format_type, :integer
    field :available, :boolean
    field :sort_value, :integer
    belongs_to :sticker_pack, StickerPack
    belongs_to :guild, Guild
    belongs_to :user, User
  end
end
