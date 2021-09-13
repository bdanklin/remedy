defmodule Remedy.Gateway.Events.VoiceStatusUpdate do
  @moduledoc false
  use Remedy.Gateway.Payload

  embedded_schema do
    field :guild_id, :integer
    field :channel_id, :integer
    field :self_mute, :boolean, default: false
    field :self_deaf, :boolean, default: false
  end

  def payload(socket, %{guild_id: _guild_id, channel_id: _channel_id} = opts) do
    {%__MODULE__{
       guild_id: opts[:guild_id],
       channel_id: opts[:channel_id],
       self_mute: opts[:self_mute] || false,
       self_deaf: opts[:self_deaf] || false
     }, socket}
  end
end
