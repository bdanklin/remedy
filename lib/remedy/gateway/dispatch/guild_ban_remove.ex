defmodule Remedy.Gateway.Dispatch.GuildBanRemove do
  @moduledoc """
  Guild Ban Remove Event
  """
  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, user: user}, socket}) do
    Cache.upsert_user(user)

    Cache.remove_ban(user_id, guild_id)
    {event, new(payload), socket}
  end

  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          user: User.t()
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    embeds_one :user, User
  end

  @doc false
  def new(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_changes()
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
