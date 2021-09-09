defmodule Remedy.Gateway.Commands.Heartbeat do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
  end

  def payload(socket, opts \\ [])

  def payload(%Websocket{sequence: nil} = socket, _opts) do
    build_payload(nil, socket)
  end

  def payload(%Websocket{sequence: sequence} = socket, _opts) do
    build_payload(sequence + 1, socket)
  end
end
