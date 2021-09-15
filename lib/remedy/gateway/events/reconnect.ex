defmodule Remedy.Gateway.Events.Reconnect do
  use Remedy.Gateway.Payload

  @spec digest(Websocket.t(), any) :: Websocket.t()
  def digest(socket, _payload) do
    socket
    |> Payload.send(:RESUME)
  end
end
