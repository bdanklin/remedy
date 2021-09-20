defmodule Remedy.Schema.User do
  @moduledoc """
  User Schema
  """
  use Remedy.Schema
  alias Remedy.CDN
  @primary_key {:id, Snowflake, autogenerate: false}

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

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
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
