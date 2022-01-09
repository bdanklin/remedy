defmodule Remedy.Schema.VoiceState do
  @moduledoc """
  Voice State Update Event
  """

  use Remedy.Schema
  @typedoc "Time at which the user requested to speak, if applicable"

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          user_id: Snowflake.t(),
          member: Member.t() | nil,
          session_id: String.t(),
          deaf?: boolean(),
          mute?: boolean(),
          self_deaf?: boolean(),
          self_mute?: boolean(),
          self_stream?: boolean(),
          self_video?: boolean(),
          suppress?: boolean(),
          request_to_speak_timestamp: ISO8601.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :user_id, Snowflake
    field :session_id, :boolean
    field :deaf?, :boolean
    field :mute?, :boolean
    field :self_deaf?, :boolean
    field :self_mute?, :boolean
    field :self_stream?, :boolean
    field :self_video?, :boolean
    field :suppress?, :boolean
    field :request_to_speak_timestamp, ISO8601
    embeds_one :member, Member
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:member)
  end
end
