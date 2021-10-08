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
