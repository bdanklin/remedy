defmodule Remedy.Schema do
  @moduledoc """
  Schema sets out all of the objects and types used within the Discord API.

  """

  defmacro __using__(_env) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      alias Remedy.Schema.{
        Activity,
        App,
        ApplicationFlags,
        ApplicationOwner,
        Attachment,
        AuditLog,
        AuditLogEntry,
        AuditLogOption,
        Ban,
        CallbackDataFlags,
        Channel,
        ChannelPinsUpdate,
        ClientStatus,
        Command,
        CommandOption,
        CommandOptionChoice,
        Component,
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
        Guild,
        GuildBanAdd,
        GuildBanRemove,
        GuildEmojisUpdate,
        GuildIntegrationsUpdate,
        GuildMemberRemove,
        GuildMembersChunk,
        GuildMemberUpdate,
        GuildRoleCreate,
        GuildRoleUpdate,
        GuildSystemChannelFlags,
        Integration,
        Interaction,
        InteractionData,
        InteractionDataOption,
        InteractionDataResolved,
        Member,
        Message,
        MessageFlags,
        MessageReaction,
        MessageReactionRemoveEmoji,
        MessageReference,
        Overwrite,
        PermissionOverwrite,
        Presence,
        PresenceUpdate,
        Provider,
        Reaction,
        Role,
        StageInstance,
        Sticker,
        StickerPack,
        Team,
        TeamMember,
        Thread,
        ThreadMember,
        ThreadMemberFlags,
        ThreadMetadata,
        UnavailableGuild,
        User,
        UserFlags,
        Voice,
        VoiceState,
        Webhook,
        WelcomeScreen,
        WelcomeScreenChannel
      }

      use Ecto.Schema
      import Ecto.Changeset

      alias Remedy.{
        ISO8601,
        Snowflake,
        Colour
      }
    end
  end
end
