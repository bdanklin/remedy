defmodule Remedy.Dispatch.Cache.Member do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          user: User.t(),
          nick: String.t(),
          avatar: String.t(),
          roles: [Role.t()],
          joined_at: ISO8601.t(),
          premium_since: ISO8601.t(),
          deaf: boolean(),
          mute: boolean(),
          pending: boolean(),
          permissions: String.t(),
          communication_disabled_until: ISO8601.t(),
          guild_id: Snowflake.t(),
          user_id: Snowflake.t()
        }

  schema "members" do
    embeds_one :user, User
    field :nick, :string
    field :avatar, :string
    field :joined_at, ISO8601
    field :premium_since, ISO8601
    field :deaf, :boolean
    field :mute, :boolean
    field :pending, :boolean, default: false
    field :permissions, :string
    field :roles, {:array, Snowflake}
    field :communication_disabled_until, ISO8601
    field :guild_id, Snowflake
    field :user_id, Snowflake
  end

  @cast ~w(id nick joined_at premium_since deaf mute pending permissions roles user_id guild_id)a
  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @cast)
    |> validate_required([:guild_id, :user_id])
  end
end
