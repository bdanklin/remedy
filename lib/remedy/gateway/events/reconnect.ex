defmodule Remedy.Gateway.Events.Reconnect do
  use Remedy.Gateway.Payload

  def digest(socket, _payload) do
    socket |> Payload.send(:RESUME)
  end
end
