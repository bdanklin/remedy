defmodule Remedy.Gateway.Dispatch.VoiceState do
  @moduledoc false
  use Remedy.Schema

  @typedoc "Guild ID this voice state is for, if applicable"
  @type guild_id :: Guild.id() | nil

  @typedoc "Channel ID this voice state is for"
  @type channel_id :: Channel.id()

  @typedoc "User this voice state is for"
  @type user_id :: User.id()

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
end
