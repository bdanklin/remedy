defmodule Remedy.Gateway.Dispatch.GuildUpdate do
  @moduledoc """
  Guild Ban Add Event

  ## Payload

  - `%Remedy.Schema.Guild{}`

  """

  alias Remedy.{Cache, Util}

  def handle({event, %{id: guild_id} = payload, socket}) do
    attrs = Map.put_new(payload, :shard, socket.shard)

    with {:ok, guild} <- Cache.update_guild(guild_id, attrs) do
      {event, guild, socket}
    else
      {:error, _changeset} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
