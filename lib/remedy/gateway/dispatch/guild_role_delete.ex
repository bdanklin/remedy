defmodule Remedy.Gateway.Dispatch.GuildRoleDelete do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  use Remedy.Schema
  alias Remedy.Cache
  alias Remedy.Schema.Role

  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :role, Role
  end

  def handle({event, %{role: role} = payload, socket}) do
    role
    |> Cache.delete_role()

    {event,
     payload
     |> new(), socket}
  end
end
