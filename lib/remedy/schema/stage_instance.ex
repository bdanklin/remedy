defmodule Remedy.Schema.StageInstance do
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "stage_instances" do
    field :topic, :string
    field :privacy_level, :integer
    field :discoverable_disabled, :boolean
    belongs_to :guild, Guild
    belongs_to :channel, Channel
    # field :tags,  :	role tags object	the tags this role has
  end
end
