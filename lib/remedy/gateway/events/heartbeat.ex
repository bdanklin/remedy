defmodule Remedy.Gateway.Events.Heartbeat do
  alias Remedy.Websocket.Command

  def digest(socket, _payload) do
    socket
    |> Command.send(:HEARTBEAT)
  end
end
