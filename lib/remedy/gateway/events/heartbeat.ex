defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload

  defp payload(%Websocket{} = socket, _opts) do
    {%{}, socket}
  end

  defp digest(socket, _payload), do: socket
end
