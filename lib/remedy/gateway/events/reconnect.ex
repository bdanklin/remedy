defmodule Remedy.Gateway.Events.Reconnect do
  use Remedy.Gateway.Payload
  @dialyzer {:nowarn_function, {:digest, 2}}

  @spec digest(Websocket.t(), any) :: Websocket.t()
  def digest(socket, _payload) do
    socket
    |> Payload.send(:RESUME)
  end
end
