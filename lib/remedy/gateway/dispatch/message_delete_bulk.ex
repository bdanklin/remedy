defmodule Remedy.Gateway.Dispatch.MessageDeleteBulk do
  @moduledoc false

  use Remedy.Schema
  alias Remedy.Cache
  alias Remedy.Schema.Message

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          ids: ids
        }

  embedded_schema do
    field :channel_id, Snowflake
    field :guild_id, Snowflake
    field :ids, {:array, :integer}, virtual: true
  end

  @typedoc "Channel id of the deleted message"
  @type channel_id :: Channel.id()

  @typedoc """
  Guild id of the deleted message

  `nil` if a non-guild message was deleted.
  """
  @type guild_id :: Guild.id() | nil

  @typedoc "Ids of the deleted messages"
  @type ids :: [Message.id(), ...]

  def handle({event, %{ids: ids} = payload, socket}) do
    for message <- ids do
      Cache.delete_message(message)
    end

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
