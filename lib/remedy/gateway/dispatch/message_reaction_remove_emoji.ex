defmodule Remedy.Gateway.Dispatch.MessageReactionRemoveEmoji do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache

  @primary_key false
  embedded_schema do
    field :message_id, Snowflake
    field :channel_id, Snowflake
    field :last_pin_timestamp, ISO8601
  end

  @doc false
  def handle({event, %{message_id: message_id} = payload, socket}) do
    Cache.remove_message_reactions(message_id)

    {event, payload |> new(), socket}
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
