defmodule Remedy.Gateway.Commands.VoiceStateUpdate do
  @moduledoc false
  defstruct guild_id: 0,
            channel_id: 0,
            self_mute: false,
            self_deaf: false

  def send(_socket, %{guild_id: guild_id, channel_id: channel_id} = opts) do
    %__MODULE__{
      guild_id: guild_id,
      channel_id: channel_id,
      self_mute: opts[:self_mute] || false,
      self_deaf: opts[:self_deaf] || false
    }
  end
end
