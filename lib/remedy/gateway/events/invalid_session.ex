defmodule Remedy.Gateway.Events.InvalidSession do
  @moduledoc false
  alias Remedy.Websocket.Command

  def digest(socket, true) do
    socket
    |> Command.send(:RESUME)
  end

  def digest(socket, false) do
    socket
    |> Command.send(:IDENTIFY)
  end
end
