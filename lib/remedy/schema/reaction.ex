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
end
