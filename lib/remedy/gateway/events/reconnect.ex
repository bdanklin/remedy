defmodule Remedy.Gateway.Events.Reconnect do
  use Remedy.Gateway.Payload

  def digest(%Websocket{} = socket, _payload) do
    socket
    |> Payload.send(:RESUME)
  end
end
