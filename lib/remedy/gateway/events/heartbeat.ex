defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload

  def payload(%Websocket{payload_sequence: payload_sequence}, _opts) do
    payload_sequence || nil
  end
end
