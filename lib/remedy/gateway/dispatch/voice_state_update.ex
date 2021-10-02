defmodule Remedy.Gateway.Dispatch.VoiceStateUpdate do
  @moduledoc false
  use Remedy.Schema

  @typedoc "Guild ID this voice state is for, if applicable"
  @type guild_id :: Snowflake.t()

  @typedoc "Channel ID this voice state is for"
  @type channel_id :: Snowflake.t()

  @typedoc "User this voice state is for"
  @type user_id :: Snowflake.t()

  @typedoc "Guild member this voice state is for, if applicable"
  @type member :: Member.t() | nil

  @typedoc "Session ID for this voice state"
  @type session_id :: String.t()

  @typedoc "Whether this user is deafened by the server"
  @type deaf? :: boolean

  @typedoc "Whether this user is muteened by the server"
  @type mute? :: boolean

  @typedoc "Whether this user is locally deafened"
  @type self_deaf? :: boolean

  @typedoc "Whether this user is locally muted"
  @type self_mute? :: boolean

  @typedoc "Whether the user is streaming using \"Go Live\""
  @type self_stream? :: boolean

  @typedoc "Whether this user's camera is enabled"
  @type self_video? :: boolean

  @typedoc "Whether this user is muted by the current user"
  @type suppress? :: boolean

  @typedoc "Time at which the user requested to speak, if applicable"
  @type request_to_speak_timestamp :: DateTime.t() | nil

  @type t :: %__MODULE__{
          guild_id: guild_id,
          channel_id: channel_id,
          user_id: user_id,
          member: member,
          session_id: session_id,
          deaf?: deaf?,
          mute?: mute?,
          self_deaf?: self_deaf?,
          self_mute?: self_mute?,
          self_stream?: self_stream?,
          self_video?: self_video?,
          suppress?: suppress?,
          request_to_speak_timestamp: request_to_speak_timestamp
        }

  @primary_key false
  embedded_schema do
    field :guild_id, :string
    field :channel_id, :string
    field :user_id, :string
    field :member, :string
    field :session_id, :string
    field :deaf?, :string
    field :mute?, :string
    field :self_deaf?, :string
    field :self_mute?, :string
    field :self_stream?, :string
    field :self_video?, :string
    field :suppress?, :string
    field :request_to_speak_timestamp, :string
  end

  def handle({event, payload, socket}) do
    {event, new(payload), socket}
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
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
