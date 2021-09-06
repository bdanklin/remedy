defmodule Remedy.Schema.VoiceState do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  embedded_schema do
    field :guild_id
    field :channel_id
    field :self_mute
    field :self_deaf
    field :gateway
    field :session
    field :token
    field :secret_key
    field :session_pid
    field :ssrc
    field :speaking
    field :ip
    field :port
    field :udp_socket
    field :rtp_sequence
    field :rtp_timestamp
    field :ffmpeg_proc
    field :raw_audio
    field :raw_stateful
    field :player_pid
  end
end
