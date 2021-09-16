defmodule Remedy.Gateway.Dispatch.GuildBanAdd do
  @moduledoc """
  Dispatched when a new guild ban is created.

  ## Payload:

  - `%Remedy.Schema.Ban{}`

  """

  alias Remedy.Schema.Ban

  def handle({event, payload, socket}) do
    {event, Ban.new(payload), socket}
  end
end
