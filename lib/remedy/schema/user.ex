defmodule Remedy.Schema.User do
  @moduledoc """
  User Schema
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          username: String.t(),
          discriminator: discriminator :: 0..9999,
          avatar: String.t() | nil,
          bot: boolean(),
          system: boolean(),
          mfa_enabled: boolean(),
          banner: String.t(),
          accent_color: Colour.t(),
          locale: String.t(),
          verified: boolean(),
          email: String.t(),
          flags: UserFlags.t(),
          premium_type: integer(),
          public_flags: UserFlags.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "users" do
    field :username, :string
    field :discriminator, :integer
    field :avatar, :string
    field :bot, :boolean, default: false
    field :system, :boolean, default: false
    field :mfa_enabled, :boolean
    field :banner, :string
    field :accent_color, :integer
    field :locale, :string
    field :verified, :boolean
    field :email, :string
    field :flags, UserFlags
    field :premium_type, :integer
    field :public_flags, UserFlags

    embeds_one :presence, Presence, on_replace: :update
    field :remedy_system, :boolean, default: false
  end

  def changeset(model \\ %__MODULE__{}, params) do
    keys = __MODULE__.__schema__(:fields) -- [:presence]

    model
    |> cast(params, keys)
    |> validate_required([:avatar, :discriminator, :id, :public_flags, :username])
    |> cast_embed(:presence)
  end

  @doc false
  def system_changeset(model \\ %__MODULE__{}, params) do
    model
    |> changeset(params)
    |> put_change(:remedy_system, true)
  end

  @doc """
  Mention a user.
  """
  @spec mention(Remedy.Schema.User.t()) :: String.t()
  def mention(user)
  def mention(%__MODULE__{id: id}), do: "<@#{to_string(id)}>"

  alias Remedy.CDN
  def avatar(user, size \\ nil)
  def avatar(%User{avatar: nil}, _size), do: nil

  def avatar(%User{id: user_id, avatar: user_avatar}, size) do
    CDN.user_avatar(user_id, user_avatar, size)
  end

  def avatar(%User{avatar: nil, discriminator: discriminator}, size) do
    CDN.default_user_avatar(discriminator, size)
  end
end
