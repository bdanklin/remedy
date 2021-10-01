defmodule Remedy.Gateway.Events.InvalidSession do
  @moduledoc false
  use Remedy.Gateway.Payload

  def digest(socket, true) do
    socket
    |> Payload.send(:RESUME)
  end

  def digest(socket, false) do
    socket
    |> Payload.send(:IDENTIFY)
  end
end