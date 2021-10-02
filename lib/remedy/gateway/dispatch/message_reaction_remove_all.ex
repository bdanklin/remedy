defmodule Remedy.Gateway.Dispatch.MessageReactionRemoveAll do
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

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
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
