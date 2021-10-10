defmodule Remedy.Gateway.Dispatch.GuildCreate do
  @moduledoc false

  #  @large_threshold 250

  alias Remedy.Cache

  def handle({event, %{id: guild_id, channels: channels} = payload, socket}) do
    payload
    |> Map.put(:shard, socket.shard)
    |> Cache.create_guild()

    for channel <- channels do
      channel
      |> Map.put_new(:guild_id, guild_id)
      |> Cache.create_channel()
    end

    {event, payload, socket}
  end
end
