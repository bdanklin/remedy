defmodule Remedy.Gateway.Events.Reconnect do
  @moduledoc false
  alias Remedy.Websocket.Command

  def digest(socket, _payload) do
    socket
    |> Command.send(:RESUME)
  end
end
