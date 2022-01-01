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

  # Primary key :message_id ++ :user_id ++ :emoji_id
  @primary_key {:id, Snowflake, autogenerate: false}
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

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end

  def new(params), do: changeset(params) |> apply_changes()
end
