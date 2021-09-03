defmodule Remedy.Schema.Emoji do
  use Remedy.Schema, :model

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "emojis" do
    field :name, :string
    field :roles, {:array, Snowflake}
    field :require_colons, :boolean
    field :managed, :boolean
    field :animated, :boolean
    field :available, :boolean
    belongs_to :user, User
    belongs_to :guild, Guild
  end

  def validate(model) do
    model
    |> validate_required([:name])
  end
end
