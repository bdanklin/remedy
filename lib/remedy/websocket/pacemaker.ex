defmodule Remedy.Websocket.Pacemaker do
  @moduledoc false
  def start(%{heartbeat_interval: heartbeat_interval, heartbeat: heartbeat} = socket) do
    %{
      socket
      | heartbeat_timer: Process.send_after(self(), :heartbeat, heartbeat_interval),
        heartbeat_ack: true,
        heartbeat_last_send: DateTime.utc_now(),
        heartbeat: heartbeat + 1
    }
  end

  def stop(%{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)
    %{socket | heartbeat: 0}
  end

  def ack_heartbeat(socket) do
    %{socket | heartbeat_ack: true, heartbeat_last_ack: DateTime.utc_now()}
  end
end
