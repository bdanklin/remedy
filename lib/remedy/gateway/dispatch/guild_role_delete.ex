defmodule Remedy.Gateway.Dispatch.GuildRoleDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, role: role}, socket}) do
    params = Map.put_new(role, :guild_id, guild_id)

    case Cache.delete_role(params) do
      {:ok, role} ->
        {event, role, socket}

      {:error, _reason} ->
        :noop
    end
  end
end
