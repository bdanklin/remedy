defmodule Remedy.Gateway.Dispatch.GuildRoleCreate do
  @moduledoc """
  Guild Role Create Event.
  """

  alias Remedy.{Cache, Util}

  def handle({event, %{guild_id: guild_id, role: role}, socket}) do
    params = Map.put_new(role, :guild_id, guild_id)

    case Cache.create_role(params) do
      {:ok, role} ->
        {event, role, socket}

      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
