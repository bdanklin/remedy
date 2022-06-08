defmodule Remedy.Gateway.Commands.Heartbeat do
  @moduledoc false
  ############################################################################
  ## 1
  ## Heartbeat
  ## Send/Receive
  ## Fired periodically by the client to keep the connection alive.

  def send(_socket, _opts) do
    %{}
  end
end
