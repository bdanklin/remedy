defmodule Remedy.ModelHelpers do
  @moduledoc false
  import Sunbake.Snowflake,
    only: [is_snowflake: 1],
    warn: false

  alias Remedy.Schema.{
    App,
    AuditLog,
    AuditLogChange,
    AuditLogEntry,
    AuditLogOption,
    Ban,
    Channel,
    Command,
    Component,
    Embed,
    Emoji,
    Guild,
    Interaction,
    InteractionData,
    InteractionDataOption,
    InteractionDataResolved,
    Member,
    Message,
    Overwrite,
    Role,
    StageInstance,
    Sticker,
    StickerPack,
    Team,
    TeamMember,
    User,
    Voice,
    VoiceState,
    Webhook
  }
end
