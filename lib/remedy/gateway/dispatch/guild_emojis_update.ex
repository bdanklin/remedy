defmodule Remedy.Gateway.Dispatch.GuildEmojisUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{emojis: emojis, guild_id: guild_id} = payload, socket}) do
    for emoji <- emojis do
      %{emoji | guild_id: guild_id}
      |> Cache.update_emoji()
    end

    {event, payload, socket}
  end
end
