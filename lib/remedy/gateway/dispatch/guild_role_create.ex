defmodule Remedy.Gateway.Dispatch.GuildRoleCreate do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.{GuildRoleCreate, Role}

  def handle({event, %GuildRoleCreate{guild_id: guild_id, role: role} = payload, socket}) do
    Cache.get_guild(guild_id)
    |> Ecto.build_assoc(:role)
    |> Role.changeset(role)
    |> Cache.create_role()

    {event, payload, socket}
  end
end
