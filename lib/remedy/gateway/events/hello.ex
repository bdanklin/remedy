defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  alias Remedy.Gateway.Session.State
  alias Remedy.Websocket.Pacemaker
  alias Remedy.Websocket.Command

  def digest(%State{session_id: nil} = socket, %{heartbeat_interval: heartbeat_interval}) do
    socket
    |> State.put_heartbeat_interval(heartbeat_interval)
    |> Command.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%State{session_id: _session_id} = socket, %{heartbeat_interval: heartbeat_interval}) do
    socket
    |> State.put_heartbeat_interval(heartbeat_interval)
    |> Command.send(:RESUME)
    |> Pacemaker.start()
  end
end
