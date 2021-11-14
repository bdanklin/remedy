defmodule Remedy.Gateway.Dispatch.GuildEmojisUpdate do
  @moduledoc false
  require Logger
  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, emojis: emojis} = _payload, socket}) do
    for emoji <- emojis do
      emoji
      |> Map.put_new(:guild_id, guild_id)
      |> Cache.update_emoji()
    end

    Cache.get_guild(guild_id)
    |> case do
      {:ok, guild} -> {event, guild, socket}
      {:error, _reason} -> :noop
    end
  end
end
