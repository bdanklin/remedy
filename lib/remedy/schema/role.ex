defmodule Remedy.Schema.Role do
  @moduledoc false
  use Remedy.Schema, :model
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
