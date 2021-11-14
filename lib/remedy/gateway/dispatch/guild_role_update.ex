defmodule Remedy.Gateway.Dispatch.GuildRoleUpdate do
  @moduledoc false

  use Remedy.Schema

  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, role: role}, socket}) do
    params = Map.put_new(role, :guild_id, guild_id)

    with {:ok, role} <- Cache.update_role(params) do
      {event, role, socket}
    else
      {:error, _reason} ->
        :noop
    end
  end
end
