defmodule Remedy.Gateway.Events.Dispatch do
  @doc """
  Dispatch
  """
  use Remedy.Gateway.Payload
  alias Remedy.Gateway.EventBroadcaster

  def digest(%Websocket{payload_dispatch_event: payload_dispatch_event} = socket, payload) do
    EventBroadcaster.digest({payload_dispatch_event, payload, socket})

    socket
  end
end
