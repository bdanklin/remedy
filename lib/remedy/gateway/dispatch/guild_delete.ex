defmodule Remedy.Gateway.Dispatch.GuildDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{id: guild_id}, socket}) do
    guild_id
    |> Cache.delete_guild()
    |> case do
      {:ok, guild} ->
        {event, guild, socket}

      {:error, _changeset} ->
        :noop
    end
  end
end
