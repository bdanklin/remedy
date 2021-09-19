defmodule Remedy.Gateway.Dispatch.GuildStickersUpdate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Sticker{}.

  """
  alias Remedy.Cache

  def handle({event, %{stickers: stickers, guild_id: guild_id} = payload, socket}) do
    for sticker <- stickers do
      {event,
       %{sticker | guild_id: guild_id}
       |> Cache.update_sticker(), socket}
    end
  end
end
