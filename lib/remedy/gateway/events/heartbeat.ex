defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload

  def payload(%WSState{} = socket, _opts) do
    {%{}, socket}
  end
end
