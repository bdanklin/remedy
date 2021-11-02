defmodule Remedy.Gateway.Dispatch.GuildCreate do
  @moduledoc """

  Guild Create Event

  ## Payload

  - `%Remedy.Schema.Guild{}`

  """
  alias Remedy.{Cache, Util}

  def handle({event, payload, socket}) do
    for p <- payload[:presences], do: Cache.update_presence(p)

    attrs = Map.put_new(payload, :shard, socket.shard)

    case Cache.update_guild(attrs) do
      {:ok, guild} ->
        {event, guild, socket}

      {:error, _reason} ->
        Util.log_malformed(event)
        :noop

      _ ->
        {:error, :unknown_error}
        Util.log_malformed(event)
        :noop
    end
  end
end
