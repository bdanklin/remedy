defmodule Remedy.Schema.Guild do
  @moduledoc """
  Discord Guild Object
  """
  use Remedy.Schema
  alias Remedy.CDN

  @type t :: %__MODULE__{
          afk_timeout: integer(),
          approximate_member_count: integer(),
          approximate_presence_count: integer(),
          banner: String.t(),
          default_message_notifications: integer(),
          description: String.t(),
          discovery_splash: String.t(),
          explicit_content_filter: integer(),
          features: [String.t()],
          icon: String.t(),
          icon_hash: String.t(),
          joined_at: ISO8601.t(),
          large: boolean(),
          max_members: integer(),
          max_presences: integer(),
          max_video_channel_users: integer(),
          member_count: integer(),
          mfa_level: integer(),
          name: String.t(),
          nsfw_level: integer(),
          permissions: String.t(),
          preferred_locale: String.t(),
          premium_subscription_count: integer(),
          premium_tier: integer(),
          region: String.t(),
          splash: String.t(),
          system_channel_flags: integer(),
          vanity_url_code: String.t(),
          verification_level: integer(),
          widget_enabled: boolean(),
          shard: integer(),
          application: App.t(),
          owner: User.t(),
          welcome_screen: WelcomeScreen.t(),
          channels: [Channel.t()],
          emojis: [Emoji.t()],
          members: [Member.t()],
          presences: [Presence.t()],
          roles: [Role.t()],
          stage_instances: [StageInstance.t()],
          stickers: [Sticker.t()],
          threads: [Thread.t()],
          voice_states: [VoiceState.t()],
          bans: [Ban.t()],
          banned_users: [User.t()],
          afk_channel: Channel.t(),
          public_updates_channel: Channel.t(),
          rules_channel: Channel.t(),
          system_channel: Channel.t(),
          widget_channel: Channel.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "guilds" do
    field :afk_timeout, :integer
    field :approximate_member_count, :integer
    field :approximate_presence_count, :integer
    field :banner, :string
    field :default_message_notifications, :integer
    field :description
    field :discovery_splash
    field :explicit_content_filter, :integer
    field :features, {:array, :string}
    field :icon, :string
    field :icon_hash, :string
    field :joined_at, ISO8601
    field :large, :boolean
    field :max_members, :integer
    field :max_presences, :integer
    field :max_video_channel_users, :integer
    field :member_count, :integer
    field :mfa_level, :integer
    field :name, :string
    field :nsfw_level, :integer
    field :permissions, :string
    field :preferred_locale, :string
    field :premium_subscription_count, :integer
    field :premium_tier, :integer
    field :region, :string
    field :splash, :string
    field :system_channel_flags, :integer
    field :vanity_url_code, :string
    field :verification_level, :integer
    field :widget_enabled, :boolean

    belongs_to :application, App
    belongs_to :owner, User

    embeds_one :welcome_screen, WelcomeScreen

    has_many :channels, Channel
    has_many :emojis, Emoji
    has_many :members, Member
    has_many :presences, Presence
    has_many :roles, Role
    has_many :stage_instances, StageInstance
    has_many :stickers, Sticker
    has_many :threads, Thread
    has_many :voice_states, VoiceState
    has_many :bans, Ban
    has_many :banned_users, through: [:bans, :users]

    has_one :afk_channel, Channel
    has_one :public_updates_channel, Channel
    has_one :rules_channel, Channel
    has_one :system_channel, Channel
    has_one :widget_channel, Channel

    field :shard, :integer
  end

  def splash(guild)
  def splash(%__MODULE__{splash: nil}), do: nil
  def splash(%__MODULE__{id: id, splash: splash}), do: CDN.guild_splash(id, splash)

  def icon(guild)
  def icon(%__MODULE__{icon: nil}), do: nil
  def icon(%__MODULE__{id: id, icon: icon}), do: CDN.guild_icon(id, icon)
end
