defmodule Remedy.Schema.User do
  @moduledoc false
  use Remedy.Schema, :model
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
    |> Integer.parse()
    |> Tuple.to_list()
    |> List.first()
    |> rem(5)
    |> CDN.embed_avatar()
  end

  def avatar(%__MODULE__{id: id, avatar: avatar}) do
    CDN.avatar(id, avatar)
  end
end

defmodule Remedy.Schema.UserFlags do
  @moduledoc false
  use Remedy.Schema, :model

  @type t :: %__MODULE__{
          DISCORD_EMPLOYEE: boolean(),
          PARTNERED_SERVER_OWNER: boolean(),
          HYPESQUAD_EVENTS: boolean(),
          BUG_HUNTER_LEVEL_1: boolean(),
          HYPESQUAD_BRAVERY: boolean(),
          HYPESQUAD_BRILLIANCE: boolean(),
          HYPESQUAD_BALANCE: boolean(),
          EARLY_SUPPORTER: boolean(),
          TEAM_USER: boolean(),
          SYSTEM: boolean(),
          BUG_HUNTER_LEVEL_2: boolean(),
          VERIFIED_BOT: boolean(),
          VERIFIED_DEVELOPER: boolean(),
          DISCORD_CERTIFIED_MODERATOR: boolean()
        }

  embedded_schema do
    field :DISCORD_EMPLOYEE, :boolean, default: false
    field :PARTNERED_SERVER_OWNER, :boolean, default: false
    field :HYPESQUAD_EVENTS, :boolean, default: false
    field :BUG_HUNTER_LEVEL_1, :boolean, default: false
    field :HYPESQUAD_BRAVERY, :boolean, default: false
    field :HYPESQUAD_BRILLIANCE, :boolean, default: false
    field :HYPESQUAD_BALANCE, :boolean, default: false
    field :EARLY_SUPPORTER, :boolean, default: false
    field :TEAM_USER, :boolean, default: false
    field :SYSTEM, :boolean, default: false
    field :BUG_HUNTER_LEVEL_2, :boolean, default: false
    field :VERIFIED_BOT, :boolean, default: false
    field :VERIFIED_DEVELOPER, :boolean, default: false
    field :DISCORD_CERTIFIED_MODERATOR, :boolean, default: false
  end

  use BattleStandard

  @flag_bits [
    {:DISCORD_EMPLOYEE, 1 <<< 0},
    {:PARTNERED_SERVER_OWNER, 1 <<< 1},
    {:HYPESQUAD_EVENTS, 1 <<< 2},
    {:BUG_HUNTER_LEVEL_1, 1 <<< 3},
    {:HYPESQUAD_BRAVERY, 1 <<< 6},
    {:HYPESQUAD_BRILLIANCE, 1 <<< 7},
    {:HYPESQUAD_BALANCE, 1 <<< 8},
    {:EARLY_SUPPORTER, 1 <<< 9},
    {:TEAM_USER, 1 <<< 10},
    {:SYSTEM, 1 <<< 12},
    {:BUG_HUNTER_LEVEL_2, 1 <<< 14},
    {:VERIFIED_BOT, 1 <<< 16},
    {:VERIFIED_DEVELOPER, 1 <<< 17},
    {:DISCORD_CERTIFIED_MODERATOR, 1 <<< 18}
  ]
end
