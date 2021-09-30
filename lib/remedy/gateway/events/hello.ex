defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%WSState{session_id: nil} = socket, %{heartbeat_interval: heartbeat_interval}) do
    %WSState{socket | heartbeat_interval: heartbeat_interval}
    |> Payload.send(:IDENTIFY)
    |> Pacemaker.start()
  end
end
