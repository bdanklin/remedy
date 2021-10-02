defmodule Remedy.Gateway.Events.Heartbeat do
  @moduledoc false
  use Remedy.Gateway.Payload
  @dialyzer {:no_missing_calls}
  def payload(%WSState{} = socket, _opts) do
    {%{}, socket}
  end
end
