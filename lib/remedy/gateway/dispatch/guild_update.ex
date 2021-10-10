defmodule Remedy.Gateway.Dispatch.GuildUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    guild =
      payload
      |> Map.put(:shard, socket.shard)
      |> Cache.update_guild()

    {event, guild, socket}
  end
end
