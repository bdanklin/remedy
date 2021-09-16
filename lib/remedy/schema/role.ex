defmodule Remedy.Schema.Role do
  @doc """
  Role
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          color: integer(),
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
    field :color, :integer
    field :hoist, :boolean
    field :position, :integer
    field :permissions, :string
    field :managed, :boolean
    field :mentionable, :boolean
    belongs_to :guild, Guild
    # field :tags,  :	role tags object	the tags this role has
  end
end
