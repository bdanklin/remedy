defmodule Remedy.Gateway.Pacemaker do
  @moduledoc false

  alias Remedy.Gateway.WSState

  def start(%WSState{heartbeat_interval: heartbeat_interval} = socket) do
    %WSState{
      socket
      | heartbeat_timer: Process.send_after(self(), :HEARTBEAT, heartbeat_interval),
        heartbeat_ack: nil,
        last_heartbeat_send: DateTime.utc_now()
    }
  end

  def stop(%WSState{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)

    socket
  end
end
