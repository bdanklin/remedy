defmodule Remedy.Schema.Member do
  use Remedy.Schema, :model
  @primary_key false

  schema "members" do
    field :nick, :string
    field :joined_at, ISO8601
    field :premium_since, ISO8601
    field :deaf, :boolean
    field :mute, :boolean
    field :pending, :boolean, default: false
    field :permissions, :string

    belongs_to :user, User

    belongs_to :guild, Guild
  end
end
