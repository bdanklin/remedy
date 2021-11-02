defmodule Remedy.Gateway.Dispatch.GuildDelete do
  @moduledoc """

  Guild Create Event

  ## Payload

  - `%Remedy.Schema.Guild{}`

  """
  alias Remedy.{Cache, Util}

  def handle({event, %{id: guild_id}, socket}) do
    case Cache.delete_guild(guild_id) do
      {:ok, guild} ->
        {event, guild, socket}

      {:error, _changeset} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
