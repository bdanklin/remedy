defmodule Remedy.Gateway.Dispatch.GuildDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    guild =
      payload
      |> Cache.delete_guild()

    {event, guild, socket}
  end
end
