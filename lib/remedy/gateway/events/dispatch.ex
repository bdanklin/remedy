defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%Websocket{session_id: nil} = socket, payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Payload.send(:IDENTIFY)
  end
end
