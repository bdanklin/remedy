defmodule Remedy.Gateway.Dispatch.GuildRoleDelete do
  @moduledoc false
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

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
