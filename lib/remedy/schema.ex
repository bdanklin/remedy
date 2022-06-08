defmodule Remedy.Schema do
  @moduledoc """
  The Remedy Schema are the standard objects that define the data structures and fields you expect to receive from the Discord API.

  Remedy performs a number of operations on the data received from the Discord API to ensure you have the data you expect.
  """

  @doc false
  def schema_alias do
    quote do
      alias Remedy.Gateway.Intents

      alias Remedy.Schema.{
        BotActivity,
        Activity,
        ActivityAssets,
        ActivityButton,
        ActivityType,
        ActivityFlags,
        ActivitySecrets,
        ActivityTimestamps,
        AllowedMentions,
        App,
        ApplicationFlags,
        ApplicationOwner,
        Attachment,
        AuditLog,
        AuditLogEntry,
        AuditLogActionType,
        AuditLogOption,
        AuditLogOptionType,
        Ban,
        Callback,
        CallbackData,
        CallbackDataFlags,
        CallbackType,
        Channel,
        ChannelType,
        ChannelPinsUpdate,
        ClientStatus,
        Command,
        CommandOption,
        CommandOptionChoice,
        CommandPermission,
        CommandPermissionType,
        CommandType,
        Component,
        ComponentType,
        ButtonStyle,
        ComponentOption,
        Embed,
        EmbedAuthor,
        EmbedField,
        EmbedFooter,
        EmbedImage,
        EmbedProvider,
        EmbedThumbnail,
        EmbedVideo,
        Emoji,
        Event,
        EventStatus,
        EventPrivacyLevel,
        EventEntityMetadata,
        EventEntityType,
        Guild,
        GuildBanAdd,
        GuildBanRemove,
        GuildDefaultMessageNotification,
        GuildEmojisUpdate,
        GuildExplicitContentFilter,
        GuildMemberRemove,
        GuildMembersChunk,
        GuildMemberUpdate,
        GuildMFALevel,
        GuildFeatures,
        GuildNSFWLevel,
        GuildPremiumTier,
        GuildRoleCreate,
        GuildRoleUpdate,
        GuildSystemChannelFlags,
        GuildVerificationLevel,
        Integration,
        IntegrationExpireType,
        IntegrationType,
        Interaction,
        IntegrationAccount,
        InteractionData,
        InteractionDataOption,
        InteractionDataResolved,
        InteractionType,
        Invite,
        InviteTargetType,
        Member,
        Message,
        MessageActivity,
        MessageActivityType,
        MessageFlags,
        MessageReaction,
        MessageReactionRemoveEmoji,
        MessageReference,
        MessageType,
        PermissionOverwrite,
        PermissionOverwriteType,
        Presence,
        PresenceUpdate,
        Provider,
        ResponseType,
        Reaction,
        Role,
        Stage,
        StagePrivacyLevel,
        Sticker,
        StickerFormatType,
        StickerPack,
        StickerType,
        SessionStartLimit,
        Team,
        TeamMember,
        TextInput,
        TextInputStyle,
        Thread,
        ThreadMember,
        ThreadMemberFlags,
        ThreadMetadata,
        UnavailableGuild,
        User,
        UserFlags,
        Voice,
        VoiceState,
        VoiceRegion,
        Webhook,
        WebhookType,
        WelcomeScreen,
        WelcomeScreenChannel
      }

      alias Remedy.{
        Colour,
        ImageData,
        ISO8601,
        Snowflake,
        Timestamp,
        URL,
        Locale
      }
    end
  end

  defmacro __using__(:schema_alias) do
    apply(__MODULE__, :schema_alias, [])
  end

  defmacro __using__(:cache_write_access) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, warn: false
      alias Remedy.Repo
      unquote(schema_alias())
    end
  end

  defmacro __using__(_options) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      use Ecto.Schema
      import Ecto.Changeset
      #    @derive {Jason.Encoder, []}
      unquote(schema_alias())
    end
  end
end
