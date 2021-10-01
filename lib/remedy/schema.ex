defmodule Remedy.Schema do
  @moduledoc """
  Remedy Schema Behaviour

  Provides some basic schema helpers and alias automatically for the internal schema.

  > Note: It is not recommended to use this behaviour within your application. Instead you can import or alias the particular schema directly. eg `alias Remedy.Schema.Guild`

  """

  @callback new(params :: map()) :: struct :: map()
  @callback update(struct :: map(), params :: map()) :: struct :: map()
  @callback validate(changeset :: Ecto.Changeset.t()) :: changeset :: Ecto.Changeset.t()

  defmacro __using__(_env) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      alias Remedy.Schema.{
        App,
        Attachment,
        AuditLog,
        AuditLogChange,
        AuditLogEntry,
        AuditLogOption,
        Ban,
        Channel,
        Command,
        Component,
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
        Integration,
        Interaction,
        InteractionData,
        InteractionDataOption,
        InteractionDataResolved,
        Member,
        Message,
        MessageReactionRemoveEmoji,
        Overwrite,
        PermissionOverwrite,
        Presence,
        Provider,
        Reference,
        Role,
        StageInstance,
        Sticker,
        StickerPack,
        Team,
        TeamMember,
        Thread,
        UnavailableGuild,
        User,
        Voice,
        VoiceState,
        Webhook,
        WelcomeScreen,
        WelcomeScreenChannel
      }

      use Ecto.Schema
      import Ecto.Changeset
      import Sunbake.Snowflake, only: [is_snowflake: 1]
      alias Sunbake.{ISO8601, Snowflake}
    end
  end
end
