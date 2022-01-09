defmodule Remedy.Gateway.Pacemaker do
  @moduledoc false

  alias Remedy.Gateway.WSState

  def start(%WSState{heartbeat_interval: heartbeat_interval} = socket) do
    timer = Process.send_after(self(), :HEARTBEAT, heartbeat_interval)
    now = DateTime.utc_now()
    %WSState{socket | heartbeat_timer: timer, heartbeat_ack: nil, last_heartbeat_send: now}
  end

  def stop(%WSState{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)
    socket
  end
end
