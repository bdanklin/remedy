defmodule Remedy.Schema.Sticker do
  @moduledoc """
  Sticker
  """
  use Remedy.Schema
  @primary_key {:id, :id, autogenerate: false}

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
