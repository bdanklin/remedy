defmodule Remedy.Websocket.Pacemaker do
  @moduledoc false
  def start(%{heartbeat_interval: heartbeat_interval} = socket) do
    %{
      socket
      | heartbeat_timer: Process.send_after(self(), :heartbeat, heartbeat_interval),
        heartbeat_ack: true,
        heartbeat_last_send: DateTime.utc_now()
    }
  end

  def stop(%{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)
    socket
  end

  def ack_heartbeat(socket) do
    %{socket | heartbeat_ack: true, heartbeat_last_ack: DateTime.utc_now()}
  end
end
