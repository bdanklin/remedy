defmodule Remedy.Gateway.Dispatch.GuildMemberUpdate do
  @moduledoc false

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end

  @moduledoc """
  Guild Member Update Event
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          #      roles: Role.t(),
          user: User.t(),
          nick: String.t(),
          avatar: String.t(),
          joined_at: ISO8601.t(),
          premium_since: ISO8601.t(),
          deaf: boolean(),
          mute: boolean(),
          pending: boolean()
        }

  embedded_schema do
    field :guild_id, Snowflake
    #    embeds_many :roles, Role
    embeds_one :user, User
    field :nick, :string
    field :avatar, :string
    field :joined_at, ISO8601
    field :premium_since, ISO8601
    field :deaf, :boolean
    field :mute, :boolean
    field :pending, :boolean
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
