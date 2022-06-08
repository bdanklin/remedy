defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  alias Remedy.Gateway.Session.WSState

  def digest(%WSState{session_id: nil} = socket, %{heartbeat_interval: heartbeat_interval}) do
    socket
    |> WSState.put_heartbeat_interval(heartbeat_interval)
    |> Command.send(:IDENTIFY)
    |> Pacemaker.start()
  end

  def digest(%WSState{} = socket, %{heartbeat_interval: heartbeat_interval}) do
    socket
    |> WSState.put_heartbeat_interval(heartbeat_interval)
    |> Command.send(:RESUME)
    |> Pacemaker.start()
  end
end
