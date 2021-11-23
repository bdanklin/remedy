defmodule Remedy.Schema.VoiceState do
  @moduledoc """
  Voice State Update Event
  """

  use Remedy.Schema

  @typedoc "Time at which the user requested to speak, if applicable"

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          user_id: Snowflake.t(),
          member: Member.t() | nil,
          session_id: String.t(),
          deaf?: boolean(),
          mute?: boolean(),
          self_deaf?: boolean(),
          self_mute?: boolean(),
          self_stream?: boolean(),
          self_video?: boolean(),
          suppress?: boolean(),
          request_to_speak_timestamp: ISO8601.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :user_id, Snowflake
    field :session_id, :boolean
    field :deaf?, :boolean
    field :mute?, :boolean
    field :self_deaf?, :boolean
    field :self_mute?, :boolean
    field :self_stream?, :boolean
    field :self_video?, :boolean
    field :suppress?, :boolean
    field :request_to_speak_timestamp, ISO8601
    embeds_one :member, Member
  end

  @doc false
  def form(params) do
    params |> changeset() |> validate() |> apply_changes()
  end

  @doc false
  def shape(model, params) do
    model |> changeset(params) |> validate() |> apply_changes()
  end

  @doc false
  def validate(changeset), do: changeset
  @doc false
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
