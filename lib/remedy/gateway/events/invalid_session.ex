defmodule Remedy.Gateway.Events.InvalidSession do
  @moduledoc false
  use Remedy.Gateway.Payload

  defp digest(socket, true) do
    socket
    |> Payload.send(:RESUME)
  end

  defp digest(socket, false) do
    socket
    |> Payload.send(:IDENTIFY)
  end

  defp payload(socket, _payload), do: {nil, socket}
end
