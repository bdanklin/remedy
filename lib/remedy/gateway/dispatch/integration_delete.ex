defmodule Remedy.Gateway.Dispatch.IntegrationDelete do

  @moduledoc false
  alias Remedy.Schema.Integration

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Integration.new(), socket}
  end
end
