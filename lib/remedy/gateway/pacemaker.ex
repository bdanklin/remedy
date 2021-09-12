defmodule Remedy.Gateway.Pacemaker do
  alias Remedy.Gateway.Websocket

  def stop(%Websocket{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)

    socket
  end

  def start(%Websocket{heartbeat_interval: heartbeat_interval} = socket) do
    socket
    |> Map.put(:heartbeat_timer, Process.send_after(self(), :HEARTBEAT, heartbeat_interval))
    |> Map.put(:heartbeat_ack, false)
    |> Map.put(:last_heartbeat_send, DateTime.utc_now())
  end
end
