defmodule Remedy.Schema.Message do
  use Remedy.Schema, :model

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "messages" do
    field :content, :string
    field :timestamp, ISO8601
    field :edited_timestamp, ISO8601
    field :tts, :boolean
    field :mention_everyone, :boolean
    has_many :mentions, User
    has_many :mention_roles, Roles
    has_many :mention_channels, Channel
    embeds_many :attachments, Attachments
    has_many :embeds, Embed
    has_many :reactions, Reaction
    field :nonce, :integer
    field :pinned, :boolean
    belongs_to :webhook, Webhook
    field :type, :integer
    has_one :activity, Activity
    belongs_to :application, Application
    #   belongs_to :message_reference,
    field :flags, :integer
    #   belongs_to :referenced_message,
    has_one :interaction, Interaction
    belongs_to :thread, Channel
    has_many :components, Component
    many_to_many :sticker_items, Sticker, join_through: "message_stickers"

    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :author, User
    belongs_to :member, Member
  end
end
