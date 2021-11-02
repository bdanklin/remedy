defmodule Remedy.Schema.VoiceState do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, :id, autogenerate: false}

  @type guild_id :: term()
  @type channel_id :: term()
  @type self_mute :: term()
  @type self_deaf :: term()
  @type gateway :: term()
  @type session :: term()
  @type token :: term()
  @type secret_key :: term()
  @type session_pid :: term()
  @type ssrc :: term()
  @type speaking :: term()
  @type ip :: term()
  @type udp_socket :: term()
  @type rtp_sequenceuence :: term()
  @type rtp_timestamp :: term()
  @type ffmpeg_proc :: term()
  @type raw_audio :: term()
  @type raw_stateful :: term()
  @type player_pid :: term()

  @type t :: %__MODULE__{
          guild_id: guild_id,
          channel_id: channel_id,
          self_mute: self_mute,
          self_deaf: self_deaf,
          gateway: gateway,
          session: session,
          token: token,
          secret_key: secret_key,
          session_pid: session_pid,
          ssrc: ssrc,
          speaking: speaking,
          ip: ip,
          port: term,
          udp_socket: udp_socket,
          rtp_sequenceuence: rtp_sequenceuence,
          rtp_timestamp: rtp_timestamp,
          ffmpeg_proc: ffmpeg_proc,
          raw_audio: raw_audio,
          raw_stateful: raw_stateful,
          player_pid: player_pid
        }

  schema "voice_states" do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :self_mute, :boolean
    field :self_deaf, :boolean
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
    field :rtp_sequenceuence
    field :rtp_timestamp
    field :ffmpeg_proc
    field :raw_audio
    field :raw_stateful
    field :player_pid
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
