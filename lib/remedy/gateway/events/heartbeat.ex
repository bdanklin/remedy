defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload

  def send(%Websocket{payload_sequence: payload_sequence} = socket, _opts) do
    payload_sequence
  end
end
