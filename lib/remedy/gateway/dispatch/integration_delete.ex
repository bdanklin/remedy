defmodule Remedy.Gateway.Dispatch.IntegrationDelete do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """

  alias Remedy.Schema.Integration

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Integration.new(), socket}
  end
end
