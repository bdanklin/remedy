defmodule Remedy.Gateway.Dispatch.GuildDelete do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    guild =
      payload
      |> Cache.delete_guild()

    {event, guild, socket}
  end
end
