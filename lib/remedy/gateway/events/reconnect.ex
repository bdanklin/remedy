defmodule Remedy.Gateway.Events.Reconnect do
  use Remedy.Gateway.Payload

  defp digest(socket, _payload) do
    socket |> Payload.send(:RESUME)
  end
end
