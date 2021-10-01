defmodule Remedy.Gateway.Dispatch.GuildRoleCreate do
  @moduledoc """
  Dispatched when a new guild role is created.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  use Remedy.Schema
  alias Remedy.Cache

  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :role, Role
  end

  def handle({event, %{guild_id: guild_id, role: role} = payload, socket}) do
    Cache.get_guild(guild_id)
    |> Ecto.build_assoc(:role)
    |> Role.changeset(role)
    |> Cache.create_role()

    {event, payload, socket}
  end

  def new(params) do
    params
    |> changeset()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> apply_changes()
  end

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end