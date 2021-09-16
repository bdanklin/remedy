defmodule Remedy.Gateway.Dispatch.GuildBanRemove do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Ban{}.

  """

  alias Remedy.Schema.Ban

  def handle({event, payload, socket}) do
    {event, Ban.new(payload), socket}
  end
end
