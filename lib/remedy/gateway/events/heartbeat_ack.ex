defmodule Remedy.Gateway.Events.HeartbeatAck do
  @moduledoc false
  alias Remedy.Gateway.Session.State
  alias Remedy.Websocket.Command
  alias Remedy.Websocket.Pacemaker

  def digest(%State{session_id: nil} = socket, _payload) do
    socket
    |> Pacemaker.ack_heartbeat()
    |> Command.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%State{} = socket, _payload) do
    socket
    |> Pacemaker.ack_heartbeat()
    |> Pacemaker.start()
  end
end
