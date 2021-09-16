defmodule Remedy.Gateway.Dispatch.Interaction do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """

  alias Remedy.Schema.Interaction

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Interaction.new(), socket}
  end
end
