defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%Websocket{session_id: session_id} = socket, payload) when is_binary(session_id) do
    %Websocket{socket | heartbeat_interval: payload["heartbeat_interval"]}
    |> Session.start_pacemaker()
    |> Payload.send(:RESUME)
  end

  def digest(%Websocket{} = socket, payload) do
    %Websocket{socket | heartbeat_interval: payload["heartbeat_interval"]}
    |> Session.start_pacemaker()
    |> Payload.send(:IDENTIFY)
  end
end
