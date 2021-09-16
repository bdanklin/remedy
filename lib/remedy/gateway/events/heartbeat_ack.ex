defmodule Remedy.Gateway.Events.HeartbeatAck do
  @doc """
  Heartbeat Acknowledge
  """
  use Remedy.Gateway.Payload

  def digest(%Websocket{session_id: nil} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Payload.send(:IDENTIFY)
  end

  def digest(%Websocket{} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
  end
end
