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
          channels: [Remedy.Schema.Channel.t()],
          emojis: [Remedy.Schema.Emoji.t()],
          members: [Remedy.Schema.Member.t()],
          #       presences: [Presence.t()],
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

  @primary_key {:id, :id, autogenerate: false}
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
    field :unavailable, :boolean
    field :system_channel_flags, :integer
    field :vanity_url_code, :string
    field :verification_level, :integer
    field :widget_enabled, :boolean

    belongs_to :application, App
    belongs_to :owner, User

    embeds_one :welcome_screen, WelcomeScreen

    has_many :channels, Channel, on_delete: :nilify_all
    has_many :emojis, Emoji, on_delete: :nilify_all
    has_many :presences, Presence
    has_many :roles, Role, on_delete: :nilify_all
    has_many :stage_instances, StageInstance, on_delete: :nilify_all
    has_many :stickers, Sticker, on_delete: :nilify_all
    has_many :threads, Thread, on_delete: :nilify_all
    has_many :integrations, Integration, on_delete: :nilify_all

    has_many :members, Member, on_delete: :nilify_all
    has_many :voice_states, VoiceState, on_delete: :nilify_all

    has_one :afk_channel, Channel
    has_one :public_updates_channel, Channel
    has_one :rules_channel, Channel
    has_one :system_channel, Channel
    has_one :widget_channel, Channel

    ## Custom
    field :shard, :integer
    has_many :bans, Ban
    has_many :banned_users, through: [:bans, :user]

    timestamps()
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params)

  def changeset(model, params) do
    to_cast = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

    model
    |> cast(params, to_cast)
    |> cast_assoc(:channels)
    |> cast_assoc(:emojis)
    |> cast_assoc(:roles)
    |> cast_assoc(:stage_instances)
    |> cast_assoc(:stickers)
    |> cast_assoc(:threads)

    #    |> cast_assoc(:presences)
    #    |> cast_assoc(:voice_states)
  end

  @spec update_emojis_changeset(
          {map, map} | %{:__struct__ => atom | %{:__changeset__ => map, optional(any) => any}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: map
  @doc false
  # Provided for the :GUILD_EMOJIS_UPDATE gateway event
  def update_emojis_changeset(model, params) do
    model
    |> cast(params, [])
    |> cast_assoc(:emojis)
  end

  @spec update_stickers_changeset(
          {map, map} | %{:__struct__ => atom | %{:__changeset__ => map, optional(any) => any}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: map
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
