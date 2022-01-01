defmodule Remedy.Schema.Role do
  @moduledoc """
  Role
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          color: Colour,
          hoist: boolean(),
          position: integer(),
          permissions: String.t(),
          managed: boolean(),
          mentionable: boolean(),
          guild: Guild.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "roles" do
    field :name, :string
    field :color, Colour
    field :hoist, :boolean
    field :position, :integer
    field :permissions, :integer
    field :managed, :boolean
    field :mentionable, :boolean
    belongs_to :guild, Guild
    # field :tags,  :	role tags object	the tags this role has
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
