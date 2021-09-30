defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc """

  """
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

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

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
