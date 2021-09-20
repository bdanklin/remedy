defmodule Remedy.Gateway.Dispatch.SpeakingUpdate do
  @moduledoc false
  use Remedy.Schema

  @typedoc """
  Id of the channel this speaking update is occurring in.
  """
  @type channel_id :: Channel.id()

  @typedoc """
  Id of the guild this speaking update is occurring in.
  """
  @type guild_id :: Guild.id()

  @typedoc """
  Boolean representing if bot has started or stopped speaking.
  """
  @type speaking :: boolean()

  @typedoc """
  Boolean representing if speaking update was caused by an audio timeout.
  """
  @type timed_out :: boolean()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          speaking: speaking,
          timed_out: timed_out
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :speaking, :boolean
    field :timed_out, :boolean
  end

  def handle({event, payload, socket}) do
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
