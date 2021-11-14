defmodule Remedy.Schema.Member do
  @moduledoc """
  Guild Member Object
  """

  use Remedy.Schema

  @type t :: %__MODULE__{
          id: :id,
          nick: String.t(),
          joined_at: ISO8601.t(),
          premium_since: ISO8601.t(),
          deaf: boolean(),
          mute: boolean(),
          pending: boolean(),
          permissions: String.t(),
          roles: [Role.t()],
          user_id: Snowflake.t(),
          guild_id: Snowflake.t()
        }

  # Primary key :guild_id ++ :user_id
  @primary_key {:id, :id, autogenerate: false}
  schema "members" do
    field :nick, :string
    field :joined_at, ISO8601
    field :premium_since, ISO8601
    field :deaf, :boolean
    field :mute, :boolean
    field :pending, :boolean, default: false
    field :permissions, :string
    field :roles, {:array, :integer}
    field :user_id, Snowflake
    field :guild_id, Snowflake

    timestamps()
  end

  @to_cast ~w(id nick joined_at premium_since deaf mute pending permissions roles user_id guild_id)a
  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    params =
      params
      |> put_pkey()
      |> Map.drop([:guild, :user])
      |> IO.inspect()

    model
    |> cast(params, @to_cast)
    |> validate_required([:guild_id, :user_id])
  end

  def put_pkey(%{user_id: user_id, guild_id: guild_id} = params) do
    id = "#{guild_id}#{user_id}" |> Integer.parse() |> elem(0)

    params
    |> Map.put_new(:id, id)
  end

  def put_pkey(params), do: params
end
