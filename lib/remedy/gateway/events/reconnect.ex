defmodule Remedy.Gateway.Events.Reconnect do
  def handle(socket, _opts) do
    socket
    |> Payload.send(:RESUME)
  end
end
