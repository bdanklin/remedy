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
          preferred_locale: String.t(),
          premium_subscription_count: integer(),
          premium_tier: integer(),
          #       region: String.t(),
          splash: String.t(),
          system_channel_flags: GuildSystemChannelFlags.t(),
          vanity_url_code: String.t(),
          verification_level: integer(),
          widget_enabled: boolean(),
          shard: integer(),
          application_id: Snowflake.t(),
          owner_id: Snowflake.t(),
          welcome_screen: WelcomeScreen.t(),
          channels: [Remedy.Schema.Channel.t()],
          emojis: [Remedy.Schema.Emoji.t()],
          members: [Remedy.Schema.Member.t()],
          #       presences: [Presence.t()],
          roles: [Role.t()],
          stage_instances: [Stage.t()],
          stickers: [Sticker.t()],
          threads: [Thread.t()],
          voice_states: [VoiceState.t()],
          bans: [Ban.t()],
          afk_channel_id: Snowflake.t(),
          public_updates_channel_id: Snowflake.t(),
          rules_channel_id: Snowflake.t(),
          system_channel_id: Snowflake.t(),
          widget_channel_id: Snowflake.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "guilds" do
    field :afk_timeout, :integer
    field :approximate_member_count, :integer
    field :approximate_presence_count, :integer
    field :banner, :string
    field :default_message_notifications, GuildDefaultMessageNotification
    field :description
    field :discovery_splash
    field :explicit_content_filter, GuildExplicitContentFilter
    field :features, GuildFeatures
    field :icon, :string
    field :icon_hash, :string
    field :joined_at, ISO8601
    field :large, :boolean
    field :max_members, :integer
    field :max_presences, :integer
    field :max_video_channel_users, :integer
    field :member_count, :integer
    field :mfa_level, GuildMfaLevel
    field :name, :string
    field :nsfw_level, GuildNsfwLevel
    field :preferred_locale, :string
    field :premium_subscription_count, :integer
    field :premium_tier, GuildPremiumTier
    #   field :region, :string
    field :splash, :string
    field :unavailable, :boolean
    field :system_channel_flags, GuildSystemChannelFlags
    field :vanity_url_code, :string
    field :verification_level, GuildVerificationLevel
    field :widget_enabled, :boolean

    #  field :permissions, :string

    field :application_id, Snowflake
    field :owner_id, Snowflake

    embeds_one :welcome_screen, WelcomeScreen

    embeds_many :channels, Channel
    embeds_many :emojis, Emoji
    embeds_many :presences, Presence
    embeds_many :roles, Role
    embeds_many :stage_instances, Stage
    embeds_many :stickers, Sticker
    embeds_many :threads, Thread
    embeds_many :members, Member
    embeds_many :voice_states, VoiceState

    embeds_many :bans, Ban

    field :afk_channel_id, Snowflake
    field :public_updates_channel_id, Snowflake
    field :rules_channel_id, Snowflake
    field :system_channel_id, Snowflake
    field :widget_channel_id, Snowflake

    ## Custom
    field :shard, :integer

    timestamps()
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params)

  def changeset(model, params) do
    to_cast = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

    model
    |> cast(params, to_cast)
  end

  @doc false
  # Provided for the :GUILD_EMOJIS_UPDATE gateway event
  def update_emojis_changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [])
    |> cast_assoc(:emojis)
  end

  @doc false
  # provided for the :GUILD_STICKERS_UPDATE gateway event.
  def update_stickers_changeset(model, params) do
    model
    |> cast(params, [])
    |> cast_assoc(:stickers)
  end

  @doc """
  Returns the URL for a guilds icon.
  """
  @spec icon(Remedy.Schema.Guild.t(), CDN.size()) :: nil | binary
  def icon(guild, size \\ nil)
  def icon(%__MODULE__{icon: nil}, _size), do: nil

  def icon(%__MODULE__{id: id, icon: icon}, size),
    do: CDN.guild_icon(id, icon, size)

  @doc """
  Returns the URL for a guilds splash.
  """
  @spec splash(Remedy.Schema.Guild.t(), CDN.size()) :: nil | binary
  def splash(guild, size \\ nil)
  def splash(%__MODULE__{splash: nil}, _size), do: nil

  def splash(%__MODULE__{id: id, splash: splash}, size),
    do: CDN.guild_splash(id, splash, size)

  @doc """
  Returns the URL for a guilds discovery splash.
  """
  @spec discovery_splash(Remedy.Schema.Guild.t(), CDN.size()) :: nil | binary
  def discovery_splash(guild, size \\ nil)
  def discovery_splash(%__MODULE__{discovery_splash: nil}, _size), do: nil

  def discovery_splash(%__MODULE__{id: id, discovery_splash: discovery_splash}, size),
    do: CDN.guild_discovery_splash(id, discovery_splash, size)

  @doc """
  Returns the URL for a guilds banner.
  """
  @spec banner(Remedy.Schema.Guild.t(), CDN.size()) :: nil | binary
  def banner(guild, size \\ nil)
  def banner(%__MODULE__{banner: nil}, _size), do: nil

  def banner(%__MODULE__{id: id, banner: banner}, size),
    do: CDN.guild_banner(id, banner, size)
end
