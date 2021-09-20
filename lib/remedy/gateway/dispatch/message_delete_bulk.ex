defmodule Remedy.Gateway.Dispatch.MessageDeleteBulk do
  @moduledoc """
  Struct representing a Message Delete Bulk event
  """

  use Remedy.Schema
  alias Remedy.Schema.Message
  alias Remedy.Cache

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
