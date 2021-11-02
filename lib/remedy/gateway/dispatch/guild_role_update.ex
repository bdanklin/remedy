defmodule Remedy.Gateway.Dispatch.GuildRoleUpdate do
  @moduledoc """
  Guild Role Update Event
  """

  alias Remedy.Cache

  use Remedy.Schema

  alias Remedy.{Cache, Util}

  def handle({event, %{id: role_id, guild_id: guild_id, role: role}, socket}) do
    params = Map.put_new(role, :guild_id, guild_id)

    with {:ok, role} <- Cache.fetch_role(role_id),
         {:ok, role} <- Cache.update_role(role, params) do
      {event, role, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
