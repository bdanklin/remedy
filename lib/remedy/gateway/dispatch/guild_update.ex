defmodule Remedy.Gateway.Dispatch.GuildUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    attrs = Map.put_new(payload, :shard, socket.shard)

    with {:ok, guild} <- Cache.update_guild(attrs) do
      {event, guild, socket}
    else
      {:error, _changeset} ->
        :noop
    end
  end
end
