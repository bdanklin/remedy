defmodule Remedy.Gateway.Dispatch.GuildStickersUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{stickers: stickers, guild_id: guild_id} = _payload, socket}) do
    for sticker <- stickers do
      {event,
       %{sticker | guild_id: guild_id}
       |> Cache.update_sticker(), socket}
    end
  end
end
