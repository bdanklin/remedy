defmodule Remedy.Gateway.Events.HeartbeatAck do
  @moduledoc false
  alias Remedy.Gateway.Session.WSState
  alias Remedy.Websocket.Command
  alias Remedy.Websocket.Pacemaker

  def digest(%WSState{session_id: nil} = socket, _payload) do
    socket
    |> Pacemaker.ack_heartbeat()
    |> Command.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%WSState{} = socket, _payload) do
    socket
    |> Pacemaker.ack_heartbeat()
    |> Pacemaker.start()
  end
end
