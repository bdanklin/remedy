defmodule Remedy.Gateway.Events.Reconnect do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(%Websocket{} = socket, _payload) do
    socket
    |> Payload.send(:RESUME)
  end
end
