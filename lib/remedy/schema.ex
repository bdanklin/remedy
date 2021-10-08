defmodule Remedy.Schema do
  @moduledoc """
  Schema sets out all of the objects and types used within the Discord API.

  > The unfortunate reason that this is required is because Discord is unreliable at delivering particular types. For example, `:id` can be returned as either an integer or a string. This is no use to man nor beast.

  It is not recommended to use this behaviour within your application. Instead you can import or alias the particular schema directly, or the whole schema module, for example:

    ```elixir
  alias Remedy.Schema.Member
  ```

  Which would make an individual resource available as [`%Member{}`](`t:Remedy.Schema.Member.t/0`).

  ```elixir
  alias Remedy.Schema, as: Discord
  ```

  Which would make all of the schema available as [`%Discord.Guild{}`](`t:Remedy.Schema.Guild.t/0`).

  ## Helper Functions

  Should you be looking for help manipulating any of the individual Schema, helper functions exist within the particular modules

  ## Callbacks

  While the callbacks within this module primarily exist for internal use only. They can be invoked to manually validate certain structs before sending them to Discord through the `Remedy.API` module.


  """

  @callback new(params :: map()) :: struct :: map()
  @callback update(struct :: map(), params :: map()) :: struct :: map()
  @callback validate(changeset :: Ecto.Changeset.t()) :: changeset :: Ecto.Changeset.t()

  defmacro __using__(_env) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      alias Remedy.Schema.{
        Activity,
        App,
        Attachment,
        AuditLog,
        AuditLogEntry,
        AuditLogOption,
        Ban,
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
        PresenceUpdate,
        Provider,
        Reaction,
        Reference,
        Role,
        StageInstance,
        Sticker,
        StickerPack,
        Team,
        TeamMember,
        Thread,
        ThreadMember,
        ThreadMetadata,
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
