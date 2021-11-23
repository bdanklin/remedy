defmodule Remedy.Schema.User do
  @moduledoc """
  User Schema
  """
  use Remedy.Schema
  alias Remedy.CDN

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
          flags: UserFlags.t(),
          premium_type: integer(),
          public_flags: integer()
        }

  @primary_key {:id, :id, autogenerate: false}
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
    field :flags, :integer
    field :premium_type, :integer
    field :public_flags, :integer
    #    has_many :messages, Message, foreign_key: :author_id
    #    has_many :guilds, Guild, foreign_key: :owner_id
    embeds_one :presence, Presence, on_replace: :update

    field :remedy_system, :boolean, default: false

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)

    model
    |> cast(params, fields -- embeds)
    |> cast_embed(:presence)
  end

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

  @doc """
  Retreive a URL of a User.
  """
  @spec avatar(%{:avatar => nil | binary, optional(any) => any}, nil | integer) :: binary
  def avatar(user, size \\ nil)
  def avatar(%{avatar: nil, discriminator: discriminator}, size), do: CDN.default_user_avatar(discriminator, size)
  def avatar(%{id: id, avatar: avatar}, size), do: CDN.user_avatar(id, avatar, size)
end
