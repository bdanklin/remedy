defmodule Remedy.Gateway.Dispatch.GuildRoleCreate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  use Remedy.Schema
  alias Remedy.Cache
  alias Remedy.Schema.Guild

  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :role, Role
  end

  def handle({event, %{guild_id: guild_id, role: role} = payload, socket}) do
    Cache.fetch_guild!(guild_id)
    |> Ecto.build_assoc(:role)
    |> Role.changeset(role)
    |> Cache.create_role()

    {event, payload, socket}
  end
end
