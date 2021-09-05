defmodule Remedy.Schema.Guild do
  @moduledoc false
  use Remedy.Schema, :model
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

    has_one :afk_channel, Channel
    has_one :public_updates_channel, Channel
    has_one :rules_channel, Channel
    has_one :system_channel, Channel
    has_one :widget_channel, Channel
  end
end

defmodule Remedy.Schema.UnavailableGuild do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "guilds" do
    field :unavailable, :boolean
  end
end
