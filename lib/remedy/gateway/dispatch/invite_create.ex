defmodule Remedy.Gateway.Dispatch.InviteCreate do
  @moduledoc false
  alias Remedy.Schema.InviteCreate

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end

  @moduledoc """
  Invite Create Gateway Event
  """
  use Remedy.Schema

  @type channel_id :: Snowflake.t()
  @type code :: String.t()
  @type created_at :: ISO8601.t()
  @type guild_id :: Snowflake.t()
  @type max_age :: integer()
  @type max_uses :: integer()
  @type target_type :: integer()
  @type temporary :: boolean()
  @type uses :: integer()
  @type inviter :: User.t()
  @type target_user :: User.t()
  @type target_application :: App.t()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          code: code,
          created_at: created_at,
          guild_id: guild_id,
          max_age: max_age,
          max_uses: max_uses,
          target_type: target_type,
          temporary: temporary,
          uses: uses,
          inviter: inviter,
          target_user: target_user,
          target_application: target_application
        }

  embedded_schema do
    field :channel_id, Snowflake
    field :code, :string
    field :created_at, ISO8601
    field :guild_id, Snowflake
    field :max_age, :integer
    field :max_uses, :integer
    field :target_type, :integer
    field :temporary, :boolean
    field :uses, :integer
    embeds_one :inviter, User
    embeds_one :target_user, User
    embeds_one :target_application, App
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
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

  @doc false
  def validate(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
