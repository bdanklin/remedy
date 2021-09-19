defmodule Remedy.Schema.User do
  @moduledoc """
  User Schema
  """
  use Remedy.Schema
  alias Remedy.CDN
  @primary_key {:id, Snowflake, autogenerate: false}

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          username: String.t(),
          discriminator: integer(),
          avatar: String.t(),
          bot: boolean(),
          system: boolean(),
          mfa_enabled: boolean(),
          banner: String.t(),
          accent_color: integer(),
          locale: String.t(),
          verified: boolean(),
          email: String.t(),
          flags: UserFlags,
          premium_type: integer(),
          public_flags: integer()
        }

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
    has_many :messages, Message, foreign_key: :author_id
    #   has_many :channels, Channel
    has_many :guilds, Guild, foreign_key: :owner_id
  end

  @doc """
  Converts a User to its _mention_ format.
  """
  @spec mention(Remedy.Schema.User.t()) :: String.t()
  def mention(user)
  def mention(%__MODULE__{id: id}), do: "<@#{to_string(id)}>"

  def avatar(user)

  def avatar(%__MODULE__{avatar: nil, discriminator: discriminator}) do
    discriminator
    |> CDN.default_user_avatar()
  end

  def avatar(%__MODULE__{id: id, avatar: avatar}) do
    CDN.user_avatar(id, avatar)
  end
end
