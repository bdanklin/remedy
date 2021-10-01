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

    def handle_event({:MESSAGE_CREATE, %Remedy.Schema.Message{content: content}, _ws_state}) do
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
  alias Remedy.Schema.{Channel, Emoji, Guild, Message, Member, Role, User}

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
          | message_ack
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
          | resumed
          | thread_create
          | thread_delete
          | thread_list_sync
          | thread_member_update
          | thread_members_update
          | thread_update
          | typing_start
          | user_update
          | voice_ready
          | voice_server_update
          | voice_speaking_update
          | voice_state_update
          | webhooks_update

  @typedoc """
  Sent when a new channel is created.
  """
  @type channel_create ::
          {:CHANNEL_CREATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a channel relevant to the current user is deleted.
  """
  @type channel_delete ::
          {:CHANNEL_DELETE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a message is pinned or unpinned in a text channel.

  This is not sent when a pinned message is deleted.
  """
  @type channel_pins_update ::
          {:CHANNEL_PINS_UPDATE, ChannelPinsUpdate.t(), WSState.t()}

  @typedoc """
  Sent when a channel is updated.

  This is not sent when the field `:last_message_id` is altered. To keep track of the `:last_message_id` changes, you must listen for `t:message_create/0` events.
  """
  @type channel_update ::
          {:CHANNEL_UPDATE, Channel.t(), WSState.t()}
  @type guild_available ::
          {:GUILD_AVAILABLE, Guild.t(), WSState.t()}
  @type guild_ban_add ::
          {:GUILD_BAN_ADD, GuildBanAdd.t(), WSState.t()}
  @type guild_ban_remove ::
          {:GUILD_BAN_REMOVE, GuildBanRemove.t(), WSState.t()}
  @type guild_create ::
          {:GUILD_CREATE, Guild.t(), WSState.t()}
  @type guild_delete ::
          {:GUILD_DELETE, Guild.t(), WSState.t()}
  @type guild_emojis_update ::
          {:GUILD_EMOJIS_UPDATE, [Emoji.t()], WSState.t()}
  @type guild_integrations_update ::
          {:GUILD_INTEGRATIONS_UPDATE, GuildIntegrationsUpdate.t(), WSState.t()}
  @type guild_member_add ::
          {:GUILD_MEMBER_ADD, Member.t(), WSState.t()}
  @type guild_member_remove ::
          {:GUILD_MEMBER_REMOVE, Member.t(), WSState.t()}
  @type guild_member_update ::
          {:GUILD_MEMBER_UPDATE, Member.t(), Member.t(), WSState.t()}
  @type guild_members_chunk ::
          {:GUILD_MEMBERS_CHUNK, map(), WSState.t()}
  @type guild_role_create ::
          {:GUILD_ROLE_CREATE, Role.t(), WSState.t()}
  @type guild_role_delete ::
          {:GUILD_ROLE_DELETE, Role.t(), WSState.t()}
  @type guild_role_update ::
          {:GUILD_ROLE_UPDATE, Role.t(), WSState.t()}
  @type guild_unavailable ::
          {:GUILD_UNAVAILABLE, UnavailableGuild.t(), WSState.t()}
  @type guild_update ::
          {:GUILD_UPDATE, Guild.t(), WSState.t()}
  @type message_ack ::
          {:MESSAGE_ACK, map, WSState.t()}
  @type message_create ::
          {:MESSAGE_CREATE, Message.t(), WSState.t()}
  @type message_delete_bulk ::
          {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), WSState.t()}
  @type message_delete ::
          {:MESSAGE_DELETE, MessageDelete.t(), WSState.t()}
  @type message_reaction_add ::
          {:MESSAGE_REACTION_ADD, MessageReactionAdd.t(), WSState.t()}
  @type message_reaction_remove_all ::
          {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), WSState.t()}
  @type message_reaction_remove_emoji ::
          {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), WSState.t()}
  @type message_reaction_remove ::
          {:MESSAGE_REACTION_REMOVE, MessageReactionRemove.t(), WSState.t()}
  @type message_update ::
          {:MESSAGE_UPDATE, Message.t(), WSState.t()}
  @type presence_update ::
          {:PRESENCE_UPDATE, Presence.t(), WSState.t()}
  @type ready ::
          {:READY, Ready.t(), WSState.t()}
  @type resumed ::
          {:RESUMED, map, WSState.t()}

  @typedoc """
  Sent when a thread is created or when the user is added to a thread.

  When being added to an existing private thread, includes a thread member object.
  """
  @type thread_create ::
          {:THREAD_CREATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a thread relevant to the current user is deleted.

  The inner payload is a subset of the channel object, containing just the id, guild_id, parent_id, and type fields.
  """
  @type thread_delete ::
          {:THREAD_DELETE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when the current user gains access to a channel.
  """
  @type thread_list_sync ::
          {:THREAD_LIST_SYNC, Channel.t(), WSState.t()}

  @typedoc """
  Sent when the thread member object for the current user is updated.

  The inner payload is a thread member object. This event is documented for completeness, but unlikely to be used by most bots. For bots, this event largely is just a signal that you are a member of the thread. See the threads docs for more details.
  """
  @type thread_member_update ::
          {:THREAD_MEMBER_UPDATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when anyone is added to or removed from a thread.

  If the current user does not have the `GUILD_MEMBERS` Gateway Intent, then this event will only be sent if the current user was added to or removed from the thread.
  """
  @type thread_members_update ::
          {:THREAD_MEMBERs_UPDATE, Channel.t(), WSState.t()}

  @typedoc """
  Sent when a thread is updated.

  The inner payload is a channel object. This is not sent when the field `:last_message_id` is altered. To keep track of the `:last_message_id` changes, you must listen for `t:message_create/0` events.
  """

  @type thread_update ::
          {:THREAD_UPDATE, Channel.t(), WSState.t()}

  @type typing_start ::
          {:TYPING_START, TypingStart.t(), WSState.t()}
  @type user_update ::
          {:USER_UPDATE, User.t(), WSState.t()}
  @type voice_ready ::
          {:VOICE_READY, VoiceReady.t(), VoiceWSState.t()}
  @type voice_server_update ::
          {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), WSState.t()}
  @type voice_speaking_update ::
          {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), VoiceWSState.t()}
  @type voice_state_update ::
          {:VOICE_STATE_UPDATE, VoiceState.t(), WSState.t()}
  @type webhooks_update ::
          {:WEBHOOKS_UPDATE, map, WSState.t()}

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour Remedy.Consumer
      @before_compile
      alias Remedy.Consumer

      def start_link(event) do
        Task.start_link(fn ->
          __MODULE__.handle_event(event)
        end)
      end

      def child_spec(_arg) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }

        Supervisor.child_spec(spec, unquote(Macro.escape(opts)))
      end

      defoverridable handle_event: 1, child_spec: 1
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def start_link do
        Consumer.start_link(__MODULE__)
      end

      def handle_event(_event) do
        :ok
      end

      def handle_event(_event) do
        :noop
      end
    end
  end

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

    ConsumerSupervisor.init(
      [
        %{
          id: mod,
          start: {mod, :start_link, []},
          restart: :transient
        }
      ],
      Keyword.merge(default, opts)
    )
  end
end
