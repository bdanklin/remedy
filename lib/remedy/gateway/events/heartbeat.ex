defmodule Remedy.Gateway.Events.Heartbeat do
  @doc """
  Heartbeat
  """
  use Remedy.Gateway.Payload

  def payload(%Websocket{} = socket, _opts) do
    {%{}, socket}
  end
end
