defmodule Remedy.Gateway.Pacemaker do
  @moduledoc false

  alias Remedy.Gateway.Websocket

  def start(%Websocket{heartbeat_interval: heartbeat_interval} = socket) do
    %Websocket{
      socket
      | heartbeat_timer: Process.send_after(self(), :HEARTBEAT, heartbeat_interval),
        heartbeat_ack: nil,
        last_heartbeat_send: DateTime.utc_now()
    }
  end

  def stop(%Websocket{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)

    socket
  end
end
