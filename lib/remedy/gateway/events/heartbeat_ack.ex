defmodule Remedy.Gateway.Events.HeartbeatAck do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%Websocket{session_id: nil} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Payload.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%Websocket{} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Pacemaker.start()
  end
end
