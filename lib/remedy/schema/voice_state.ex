defmodule Remedy.Schema.VoiceState do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, :id, autogenerate: false}

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
    field :rtp_sequenceuence
    field :rtp_timestamp
    field :ffmpeg_proc
    field :raw_audio
    field :raw_stateful
    field :player_pid
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
