defmodule Remedy.Gateway.Events.HeartbeatAck do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%WSState{session_id: nil} = socket, _payload) do
    %WSState{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Payload.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%WSState{} = socket, _payload) do
    %WSState{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Pacemaker.start()
  end
end
