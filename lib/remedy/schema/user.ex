defmodule Remedy.Schema.User do
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "users" do
    field :username, :string
    field :discriminator, :string
    field :avatar, :string
    field :bot, :boolean
    field :system, :boolean
    field :mfa_enabled, :boolean
    field :banner, :string
    field :accent_color, :integer
    field :locale, :string
    field :verified, :boolean
    field :email, :string
    field :flags, :integer
    field :premium_type, :integer
    field :public_flags, :integer
    has_many :messages, Message
    has_many :channels, Channel
    has_many :guilds, Guild
  end
end
