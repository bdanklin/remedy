defmodule Remedy.Gateway.Dispatch.GuildRoleCreate do
  @moduledoc """
  Guild Role Create Event.
  """
  use Remedy.Schema
  alias Remedy.Cache

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          role: Role.t()
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :role, Role
  end

  def handle({event, %{guild_id: guild_id, role: role} = payload, socket}) do
    Cache.create_role(guild_id, role)

    {event, new(payload), socket}
  end

  @doc false
  def new(params) do
    %__MODULE__{}
    |> cast(params, [:guild_id])
    |> cast_embed(:role)
    |> apply_changes()
  end
end
