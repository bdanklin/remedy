defmodule Remedy.Gateway.Dispatch.GuildRoleUpdate do
  @moduledoc """
  Guild Role Update Event
  """

  alias Remedy.Cache
  alias Remedy.Schema.{GuildRoleUpdate, Role}

  def handle({event, %{guild_id: guild_id, role: role} = payload, socket}) do
    Cache.get_guild(guild_id)
    |> Ecto.build_assoc(:role)
    |> Role.changeset(role)
    |> Cache.delete_role()

    {event, GuildRoleUpdate.new(payload), socket}
  end
end
