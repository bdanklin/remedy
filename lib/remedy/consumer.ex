defmodule Remedy.Consumer do
  @moduledoc """
  Consumer process for gateway event handling.

  ## Consuming Dispatch Events
  To handle events, Remedy uses a GenStage implementation.

  Remedy defines the `producer` and `producer_consumer` in the GenStage design.
  To consume the events you must create at least one `consumer` process.

  Remedy uses a ConsumerSupervisor to dispatch events, meaning your handlers
  will each be ran in their own seperate task.

  The full list of dispatch events and their inner payload is described in the type specs within this module.

  - Regular payloads are delivered after casting to their schema and ratified against the cache.
  - Irregular payloads are classified as those which do not directly map to a standard discord object. They undergo extensive manipulation prior to updating the cache. They are described under the `DISPATCH` section of the documentation.

  ## Example

  It is recommended that you supervise your consumers. First we set up a supervisor module for our consumers.

  ```elixir
  #example_supervisor.ex
  defmodule MyApp.ExampleSupervisor do
    use Supervisor

    def start_link(args) do
      Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    end

    @impl true
    def init(_init_arg) do
      children = [ExampleConsumer]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
  ```

  You can then set up your consumer module.

  ```elixir
  #example_consumer.ex
  defmodule ExampleConsumer do
    use Remedy.Consumer

    alias Remedy.Api

    def start_link do
      Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, %Message{content: content}, _ws_state}) do
      case content do
        "!sleep" ->
          Api.create_message(msg.channel_id, "Going to sleep...")
          Process.sleep(3000)

        "!ping" ->
          Api.create_message(msg.channel_id, "pyongyang!")

        "!raise" ->
          raise "No problems here!"
      end
    end

    def handle_event(_event) do
      :noop
    end
  end
  ```

  """

  use ConsumerSupervisor

  alias Remedy.Gateway.{EventBuffer, WSState}

  alias Remedy.Schema.{
    Channel,
    Guild,
    Integration,
    Interaction,
    Member,
    Message,
    MessageDeleteBulk,
    MessageReactionRemoveAll,
    MessageReactionRemoveEmoji,
    Ready,
    ThreadListSync,
    ThreadMember,
    TypingStart,
    User,
    VoiceState,
    WebhooksUpdate
  }

  @callback handle_event(event) :: any

  @callback handle_event(any()) :: :noop

  @type event ::
          channel_create
          | channel_delete
          | channel_pins_update
          | channel_update
          | guild_available
          | guild_ban_add
          | guild_ban_remove
          | guild_create
          | guild_delete
          | guild_emojis_update
          | guild_integrations_update
          | guild_member_add
          | guild_member_remove
          | guild_member_update
          | guild_members_chunk
          | guild_role_create
          | guild_role_delete
          | guild_role_update
          | guild_unavailable
          | guild_update
          | integration_create
          | integration_update
          | integration_delete
          | interaction_create
          | message_create
          | message_delete_bulk
          | message_delete
          | message_reaction_add
          | message_reaction_remove_all
          | message_reaction_remove_emoji
          | message_reaction_remove
          | message_update
          | presence_update
          | ready
          | thread_create
          | thread_delete
          | thread_list_sync
          | thread_member_update
          | thread_members_update
          | thread_update
          | typing_start
          | user_update
          | webhooks_update

  @typedoc """
  Sent when a new channel is created.

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-create)
  """
  @type channel_create ::
          {:CHANNEL_CREATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a channel is updated.

  This is not sent when the field `:last_message_id` is altered. To keep track of the `:last_message_id` changes, you must listen for `t:message_create/0` events.

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-update)
  """
  @type channel_update ::
          {:CHANNEL_UPDATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a channel relevant to the current user is deleted.

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-delete)
  """
  @type channel_delete ::
          {:CHANNEL_DELETE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a message is pinned or unpinned in a text channel.

  This is not sent when a pinned message is deleted.

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-pins-update)
  """
  @type channel_pins_update ::
          {:CHANNEL_UPDATE, Channel.t(), WSState.t()}

  ## Is this real?
  @typep guild_available ::
           {:GUILD_AVAILABLE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when a user is banned from a guild.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-ban-add)
  """
  @type guild_ban_add ::
          {:GUILD_BAN_ADD, Ban.t(), WSState.t()}

  @typedoc """
  Sent when a user is unbanned from a guild.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-ban-remove)
  """
  @type guild_ban_remove ::
          {:GUILD_BAN_REMOVE, Ban.t(), WSState.t()}

  @typedoc """
  This event can be sent in three different scenarios:

  1. When a user is initially connecting, to lazily load and backfill information for all unavailable guilds sent in the Ready event. Guilds that are unavailable due to an outage will send a Guild Delete event.
  2. When a Guild becomes available again to the client.
  3. When the current user joins a new Guild.

  The inner payload is a guild object, with all the extra fields specified.

  > Note: If your bot does not have the `:GUILD_PRESENCES` Gateway Intent, or if the guild has over 75k members, members and presences returned in this event will only contain your bot and users in voice channels.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-create)
  """
  @type guild_create :: {:GUILD_CREATE, Guild.t(), WSState.t()}

  @typedoc """

  Sent when a guild becomes or was already unavailable due to:

  1. An outage
  2. The user leaves or is removed from a guild.

  The inner payload is an unavailable guild object. If the unavailable field is not set, the user was removed from the guild.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-delete)
  """
  @type guild_delete :: {:GUILD_DELETE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when a guild's emojis have been updated.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-emojis-update)
  """
  @type guild_emojis_update :: {:GUILD_EMOJIS_UPDATE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when a guild integration is updated.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-integrations-update)

  """
  @type guild_integrations_update ::
          {:GUILD_INTEGRATIONS_UPDATE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when a new user joins a guild.

  ## Intents

  - `:GUILD_MEMBERS`

  The inner payload is a guild member object with an extra guild_id.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-add)
  """
  @type guild_member_add ::
          {:GUILD_MEMBER_ADD, Member.t(), WSState.t()}

  @typedoc """
  Sent when a used is removed from a guild.

  ## Intents

  - `:GUILD_MEMBERS`

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-remove)
  """
  @type guild_member_remove ::
          {:GUILD_MEMBER_REMOVE, Member.t(), WSState.t()}

  @typedoc """
  Sent when a guild member is updated.

  ## Intents

  - `:GUILD_MEMBERS`

  This will also fire when the user object of a guild member changes.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-update)
  """
  @type guild_member_update ::
          {:GUILD_MEMBER_UPDATE, Member.t(), Member.t(), WSState.t()}

  @typedoc """
  Sent in response to Guild Request Members.

  > Note: While this event *can* be consumed if you so desire, it is kind of pointles, and used internally for the cache.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-members-chunk)
  """
  @type guild_members_chunk ::
          {:GUILD_MEMBERS_CHUNK, GuildMembersChunk.t(), WSState.t()}

  @typedoc """
  Sent when a guild role is created.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-create)
  """
  @type guild_role_create ::
          {:GUILD_ROLE_CREATE, Role.t(), WSState.t()}

  @typedoc """
  Sent when a guild role is deleted.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-delete)
  """
  @type guild_role_delete ::
          {:GUILD_ROLE_DELETE, Role.t(), WSState.t()}

  @typedoc """
  Sent when a guild role is updated.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-update)
  """
  @type guild_role_update ::
          {:GUILD_ROLE_UPDATE, Role.t(), WSState.t()}

  ## does this exist?
  @typep guild_unavailable ::
           {:GUILD_UNAVAILABLE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when a guild is updated.

  The inner payload is a guild object.

  [Read More](https://discord.com/developers/docs/topics/gateway#guild-update)
  """
  @type guild_update ::
          {:GUILD_UPDATE, Guild.t(), WSState.t()}

  @typedoc """
  Sent when an integration is created.

  [Read More](https://discord.com/developers/docs/topics/gateway#integration-create)
  """
  @type integration_create ::
          {:INTEGRATION_CREATE, Integration.t(), WSState.t()}

  @typedoc """
  Sent when an integration is updated.

  [Read More](https://discord.com/developers/docs/topics/gateway#integration-update)
  """
  @type integration_update ::
          {:INTEGRATION_UPDATE, Integration.t(), WSState.t()}

  @typedoc """
  Sent when an integration is deleted.

  [Read More](https://discord.com/developers/docs/topics/gateway#integration-delete)

  """
  @type integration_delete ::
          {:INTEGRATION_DELETE, Integration.t(), WSState.t()}

  @typedoc """
  Sent when a user triggers an `Application Command`

  Inner payload is an Interaction.

  [Read More](https://discord.com/developers/docs/topics/gateway#interaction-create)
  """
  @type interaction_create ::
          {:INTERACTION_CREATE, Interaction.t(), WSState.t()}

  @typedoc """
  Sent when a message is created.

  The inner payload is a message object.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-create)
  """
  @type message_create ::
          {:MESSAGE_CREATE, Message.t(), WSState.t()}

  @typedoc """
  Sent when multiple messages are deleted at once.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-delete-bulk)
  """
  @type message_delete_bulk ::
          {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), WSState.t()}

  @typedoc """
  Sent when a messgae is deleted.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-delete)
  """
  @type message_delete ::
          {:MESSAGE_DELETE, Message.t(), WSState.t()}

  @typedoc """
  Sent when a user adds a reaction to a message.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-add)
  """
  @type message_reaction_add ::
          {:MESSAGE_REACTION_ADD, Reaction.t(), WSState.t()}

  @typedoc """
  Sent when a user removes a reaction from a message.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove)
  """
  @type message_reaction_remove_all ::
          {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), WSState.t()}

  @typedoc """
  Sent when a bot removes all instances of a given emoji from the reactions of a message.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove-emoji)
  """
  @type message_reaction_remove_emoji ::
          {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), WSState.t()}

  @typedoc """
  Sent when a user removes a reaction from a message.

  [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove)
  """
  @type message_reaction_remove ::
          {:MESSAGE_REACTION_REMOVE, MessageReactionRemove.t(), WSState.t()}

  @typedoc """
  Sent when a message is updated.

  > Note: Unlike creates, message updates may contain only a subset of the full message object payload (but will always contain an id and channel_id).

  [Read More](https://discord.com/developers/docs/topics/gateway#message-update)
  """
  @type message_update ::
          {:MESSAGE_UPDATE, Message.t(), WSState.t()}

  @typedoc """
  This event is sent when a user's presence or info, such as name or avatar, is updated.

  ## Intents

  - `:GUILD_PRESENCES`

  > Note: The user object within this event can be partial, the only field which must be sent is the id field, everything else is optional. Along with this limitation, no fields are required, and the types of the fields are not validated. Your client should expect any combination of fields and types within this event.
  """
  @type presence_update :: {:PRESENCE_UPDATE, User.t(), WSState.t()}
  @type ready :: {:READY, Ready.t(), WSState.t()}

  @typedoc """
  Sent when a thread is created or when the user is added to a thread.

  When being added to an existing private thread, includes a thread member object.

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-delete)
  """
  @type thread_create :: {:THREAD_CREATE, Thread.t(), WSState.t()}

  @typedoc """
  Sent when a thread relevant to the current user is deleted.

  The inner payload is a subset of the channel object, containing just the id, guild_id, parent_id, and type fields.

  [Read More](https://discord.com/developers/docs/topics/gateway#thread-delete)
  """
  @type thread_delete ::
          {:THREAD_DELETE, Thread.t(), WSState.t()}

  @typedoc """
  Sent when the current user gains access to a channel.

  [Read More](https://discord.com/developers/docs/topics/gateway#thread-list-sync-thread-list-sync-event-fields)
  """
  @type thread_list_sync ::
          {:THREAD_LIST_SYNC, ThreadListSync.t(), WSState.t()}

  @typedoc """
  Sent when the thread member object for the current user is updated.

  The inner payload is a thread member object. This event is documented for completeness, but unlikely to be used by most bots. For bots, this event largely is just a signal that you are a member of the thread. See the threads docs for more details.
  """
  @type thread_member_update ::
          {:THREAD_MEMBER_UPDATE, ThreadMember.t(), WSState.t()}

  @typedoc """
  Sent when anyone is added to or removed from a thread.

  If the current user does not have the `GUILD_MEMBERS` Gateway Intent, then this event will only be sent if the current user was added to or removed from the thread.
  """
  @type thread_members_update ::
          {:THREAD_MEMBERS_UPDATE, ThreadMember.t(), WSState.t()}

  @typedoc """
  Sent when a thread is updated.

  The inner payload is a channel object. This is not sent when the field `:last_message_id` is altered. To keep track of the `:last_message_id` changes, you must listen for `t:message_create/0` events.
  """

  @type thread_update ::
          {:THREAD_UPDATE, Thread.t(), WSState.t()}

  @typedoc """
  Sent when a user begins typing in a channel.
  """
  @type typing_start ::
          {:TYPING_START, TypingStart.t(), WSState.t()}

  @typedoc """
  Sent when a user is updated.
  """
  @type user_update ::
          {:USER_UPDATE, User.t(), WSState.t()}

  @typedoc """
  Sent when a user's voice state is updated.
  """
  @type voice_state_update ::
          {:VOICE_STATE_UPDATE, VoiceState.t(), WSState.t()}

  @typedoc """
  Sent when a webhook is updated.
  """
  @type webhooks_update ::
          {:WEBHOOKS_UPDATE, WebhooksUpdate.t(), WSState.t()}

  ## voice_server_update :: {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), WSState.t()}
  ## voice_ready :: {:VOICE_READY, VoiceReady.t(), VoiceWSState.t()}
  ## voice_speaking_update :: {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), VoiceWSState.t()}

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour Remedy.Consumer
      alias Remedy.Consumer

      def start_link(event) do
        Task.start_link(fn -> __MODULE__.handle_event(event) end)
      end

      def child_spec(_arg) do
        spec = %{id: __MODULE__, start: {__MODULE__, :start_link, []}}

        Supervisor.child_spec(spec, unquote(Macro.escape(opts)))
      end

      def handle_event(_event) do
        :ok
      end

      defoverridable handle_event: 1, child_spec: 1
    end
  end

  @spec start_link(any, keyword) :: :ignore | {:error, any} | {:ok, pid}
  @doc false
  def start_link(mod, opts \\ []) do
    {mod_and_opts, cs_opts} =
      case Keyword.pop(opts, :name) do
        {nil, mod_opts} -> {[mod, mod_opts], []}
        {cs_name, mod_opts} -> {[mod, mod_opts], [name: cs_name]}
      end

    ConsumerSupervisor.start_link(__MODULE__, mod_and_opts, cs_opts)
  end

  @doc false
  def init([mod, opts]) do
    default = [strategy: :one_for_one, subscribe_to: [EventBuffer]]
    opts = Keyword.merge(default, opts)
    child_spec = [%{id: mod, start: {mod, :start_link, []}, restart: :transient}]

    ConsumerSupervisor.init(child_spec, opts)
  end
end
