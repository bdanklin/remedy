defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          last_pin_timestamp: ISO8601.t()
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :last_pin_timestamp, ISO8601
  end

  def handle({event, payload, socket}) do
    %{
      id: payload.channel_id,
      guild_id: payload.guild_id,
      last_pin_timestamp: payload.last_pin_timestamp
    }
    |> Cache.update_channel()

    {event, new(payload), socket}
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
