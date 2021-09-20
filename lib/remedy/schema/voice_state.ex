defmodule Remedy.Schema.VoiceState do
  @moduledoc false
  use Remedy.Schema
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

  # def ready_for_ws?(%__MODULE__{} = v) do
  #   not (is_pid(v.session_pid) or
  #          is_nil(v.session) or
  #          is_nil(v.gateway) or
  #          is_nil(v.token))
  # end

  # def ready_for_ws?(_), do: false

  # def ready_for_rtp?(%__MODULE__{} = v) do
  #   not (is_nil(v.ip) or
  #          is_nil(v.port) or
  #          is_nil(v.ssrc) or
  #          is_nil(v.secret_key) or
  #          is_nil(v.udp_socket))
  # end

  # def ready_for_rtp?(_), do: false

  # def playing?(%__MODULE__{} = v) do
  #   is_pid(v.player_pid) and Process.alive?(v.player_pid)
  # end

  # def playing?(_), do: false

  # def cleanup(%__MODULE__{} = v) do
  #   unless is_nil(v.player_pid) do
  #     if Process.alive?(v.player_pid) do
  #       Process.exit(v.player_pid, :cleanup)
  #     end
  #   end

  #   unless is_nil(v.ffmpeg_proc) do
  #     if Proc.alive?(v.ffmpeg_proc) do
  #       Proc.stop(v.ffmpeg_proc)
  #     end
  #   end

  #   unless is_nil(v.udp_socket) do
  #     :gen_udp.close(v.udp_socket)
  #   end

  #   unless is_nil(v.session_pid) do
  #     if Process.alive?(v.session_pid) do
  #       Remedy.Voice.Session.close_connection(v.session_pid)
  #     end
  #   end

  #   :ok
  # end

  # def cleanup(_), do: :ok
end
