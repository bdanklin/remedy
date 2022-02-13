defmodule Remedy.Dispatch.Payloads.VoiceStateUpdate do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :user_id, Snowflake
    field :session_id, :boolean
    field :deaf, :boolean
    field :mute, :boolean
    field :self_deaf, :boolean
    field :self_mute, :boolean
    field :self_stream, :boolean
    field :self_video, :boolean
    field :suppress, :boolean
    field :request_to_speak_timestamp, ISO8601
    embeds_one :member, Member
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [
      :guild_id,
      :channel_id,
      :user_id,
      :session_id,
      :deaf,
      :mute,
      :self_deaf,
      :self_mute?,
      :self_stream,
      :self_video,
      :suppress,
      :request_to_speak_timestamp
    ])
    |> cast_embed(:member)
  end
end
