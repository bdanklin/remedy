defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload

  def payload(%Websocket{} = socket, _opts) do
    {%{}, socket}
  end

  def digest(socket, _payload), do: socket
end
