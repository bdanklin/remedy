defmodule Remedy.Schema.Sticker do
  @moduledoc """
  Sticker
  """
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  @type t :: %__MODULE__{
          name: String.t(),
          asset: String.t(),
          description: String.t(),
          tags: String.t(),
          type: StickerType.t(),
          format_type: StickerFormatType.t(),
          available: boolean(),
          sort_value: integer(),
          sticker_pack: StickerPack.t(),
          guild: Guild.t(),
          user: User.t()
        }

  schema "stickers" do
    field :name, :string
    field :asset, :string
    field :description, :string
    field :tags, :string
    field :type, StickerType
    field :format_type, StickerFormatType
    field :available, :boolean
    field :sort_value, :integer
    embeds_one :sticker_pack, StickerPack
    belongs_to :guild, Guild
    belongs_to :user, User
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end

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
  schema "sticker_packs" do
    field :name, :string
    field :description, :string
    field :banner_asset_id, Snowflake, virtual: true
    # field :sku_id	snowflake	id of the pack's SKU

    embeds_one :cover_sticker, Sticker
    embeds_many :stickers, Sticker
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
