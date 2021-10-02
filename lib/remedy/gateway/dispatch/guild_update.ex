defmodule Remedy.Gateway.Dispatch.GuildUpdate do
  @moduledoc false
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
