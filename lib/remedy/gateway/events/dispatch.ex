defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%Websocket{} = socket, payload) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> Dispatch.handle()
  end
end
