defmodule Remedy.Schema.SpeakingUpdate do
  @moduledoc false
  use Remedy.Schema

  @typedoc """
  Id of the channel this speaking update is occurring in.
  """
  @type channel_id :: Snowflake.t()

  @typedoc """
  Id of the guild this speaking update is occurring in.
  """
  @type guild_id :: Snowflake.t()

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

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
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
