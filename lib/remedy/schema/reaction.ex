defmodule Remedy.Schema.Reaction do
  @moduledoc """
  Message Reaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user: User.t(),
          channel: Channel.t(),
          message: Message.t(),
          guild: Guild.t(),
          member: Member.t(),
          count: integer(),
          me: boolean(),
          emoji: Emoji.t()
        }

  @primary_key false
  embedded_schema do
    embeds_one :user, User
    embeds_one :channel, Channel
    embeds_one :message, Message
    embeds_one :guild, Guild
    embeds_one :member, Member
    field :count, :integer
    field :me, :boolean
    embeds_one :emoji, Emoji
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
