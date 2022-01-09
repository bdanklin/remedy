defmodule Remedy.Schema.Template do
  @moduledoc """
  Template Object
  """
  use Remedy.Schema

  @primary_key {:code, :string, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :description, :string
    field :usage_count, :integer
    field :creator_id, Snowflake
    field :created_at, ISO8601
    field :updated_at, ISO8601
    field :source_guild_id, Snowflake
    field :is_dirty, :boolean
    embeds_one :creator, User
    embeds_one :serialized_source_guild, Guild
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [
      :name,
      :description,
      :usage_count,
      :creator_id,
      :created_at,
      :updated_at,
      :source_guild_id,
      :is_dirty
    ])
    |> cast_embed(:creator)
    |> cast_embed(:serialized_source_guild)
  end
end
