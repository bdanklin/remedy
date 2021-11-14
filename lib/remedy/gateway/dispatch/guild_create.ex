defmodule Remedy.Gateway.Dispatch.GuildCreate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    for p <- payload[:presences], do: Cache.update_presence(p)
    for c <- payload[:channels], do: Cache.update_channel(c)

    attrs = Map.put_new(payload, :shard, socket.shard)

    case Cache.update_guild(attrs) do
      {:ok, guild} ->
        {event, guild, socket}

      _ ->
        :noop
    end
  end
end
