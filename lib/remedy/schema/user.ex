defmodule Remedy.Schema.User do
  @moduledoc """
  User Schema
  """
  use Remedy.Schema
  alias Remedy.CDN

  @type id :: Snowflake.t()
  @type username :: String.t()
  @type discriminator :: integer()
  @type avatar :: String.t()
  @type bot :: boolean()
  @type system :: boolean()
  @type mfa_enabled :: boolean()
  @type banner :: String.t()
  @type accent_color :: integer()
  @type locale :: String.t()
  @type verified :: boolean()
  @type email :: String.t()
  @type flags :: UserFlags
  @type premium_type :: integer()
  @type public_flags :: integer()

  @type t :: %__MODULE__{
          id: id,
          username: username,
          discriminator: discriminator,
          avatar: avatar,
          bot: bot,
          system: system,
          mfa_enabled: mfa_enabled,
          banner: banner,
          accent_color: accent_color,
          locale: locale,
          verified: verified,
          email: email,
          flags: flags,
          premium_type: premium_type,
          public_flags: public_flags
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "users" do
    field :username, :string
    field :discriminator, :integer
    field :avatar, :string
    field :bot, :boolean
    field :system, :boolean
    field :mfa_enabled, :boolean
    field :banner, :string
    field :accent_color, :any, virtual: true
    field :locale, :string
    field :verified, :boolean
    field :email, :string
    field :flags, :integer
    field :premium_type, :integer
    field :public_flags, :integer
    has_many :messages, Message, foreign_key: :author_id
    has_many :guilds, Guild, foreign_key: :owner_id
    embeds_one :presence, Presence, on_replace: :update

    field :remedy_system, :boolean, default: false, redact: true

    timestamps()
  end

  @doc false
  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()

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
