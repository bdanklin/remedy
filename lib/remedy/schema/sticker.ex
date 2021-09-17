defmodule Remedy.Schema.Sticker do
  @moduledoc """
  Sticker
  """
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          tags: String.t(),
          type: integer(),
          format_type: integer(),
          available: boolean(),
          sort_value: integer(),
          sticker_pack: StickerPack.t(),
          guild: Guild.t(),
          user: User.t()
        }

  embedded_schema do
    field :name, :string
    field :description, :string
    field :tags, :string
    field :type, :integer
    field :format_type, :integer
    field :available, :boolean
    field :sort_value, :integer
    belongs_to :sticker_pack, StickerPack
    belongs_to :guild, Guild
    belongs_to :user, User
  end
end
