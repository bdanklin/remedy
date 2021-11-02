defmodule Remedy.Gateway.Dispatch.GuildRoleDelete do
  @moduledoc """
  Guild Role Delete Event

  ## Payload

  - `%Remedy.Schema.Role{}`

  """
  alias Remedy.{Cache, Util}

  def handle({event, %{guild_id: guild_id, role: role}, socket}) do
    params = Map.put_new(role, :guild_id, guild_id)

    case Cache.delete_role(params) do
      {:ok, role} ->
        {event, role, socket}

      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
