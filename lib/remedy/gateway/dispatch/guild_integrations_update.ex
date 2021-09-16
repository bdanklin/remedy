defmodule Remedy.Gateway.Dispatch.GuildUpdate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  alias Remedy.Cache
  alias Remedy.Schema.Guild

  def handle({event, payload, socket}) do
    guild =
      payload
      |> Map.put(:shard, socket.shard)
      |> Guild.new()
      |> Cache.update_guild()

    {event, guild, socket}
  end
end
