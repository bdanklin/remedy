defmodule Remedy.Gateway.Events.HeartbeatAck do
  @moduledoc false
  use Remedy.Gateway.Payload

  def payload(socket, opts \\ []), do: {:noop, socket}

  def digest(%Websocket{session_id: nil} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Payload.send(:IDENTIFY)
  end

  def digest(%Websocket{} = socket, _payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
  end
end
