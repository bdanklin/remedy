defmodule Remedy.Gateway.Dispatch.GuildIntegrationsUpdate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end
end
