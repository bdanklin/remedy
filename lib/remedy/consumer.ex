defmodule Remedy.Consumer do
  @moduledoc """
  Consumer process for gateway event handling.

  # Consuming Gateway Events
  To handle events, Remedy uses a GenStage implementation.

  Remedy defines the `producer` and `producer_consumer` in the GenStage design.
  To consume the events you must create at least one `consumer` process. It is
  generally recommended that you spawn a consumer per core. To find this number
  you can use `System.schedulers_online/0`.

  Remedy uses a ConsumerSupervisor to dispatch events, meaning your handlers
  will each be ran in their own seperate task.

  ## Example
  An example consumer can be found
  [here](https://github.com/bdanklin/remedy/blob/master/examples/event_consumer.ex).
  """

  use ConsumerSupervisor

  alias Remedy.Shard.Stage.EventBuffer
  alias Remedy.Struct.{Channel, VoiceWSState, Websocket}

  alias Remedy.Struct.Event.{
    ChannelPinsUpdate,
    GuildBanAdd,
    GuildBanRemove,
    GuildIntegrationsUpdate,
    MessageDelete,
    MessageDeleteBulk,
    MessageReactionAdd,
    MessageReactionRemove,
    MessageReactionRemoveAll,
    MessageReactionRemoveEmoji,
    Ready,
    SpeakingUpdate,
    TypingStart,
    VoiceReady,
    VoiceServerUpdate,
    VoiceState
  }

  @callback handle_event(event) :: any

  @type channel_create ::
          {:CHANNEL_CREATE, Channel.t(), Websocket.t()}
  @type channel_delete ::
          {:CHANNEL_DELETE, Channel.t(), Websocket.t()}

  @type channel_update ::
          {:CHANNEL_UPDATE, {old_channel :: Channel.t() | nil, new_channel :: Channel.t()}, Websocket.t()}
  @type channel_pins_ack ::
          {:CHANNEL_PINS_ACK, map, Websocket.t()}
  @type channel_pins_update ::
          {:CHANNEL_PINS_UPDATE, ChannelPinsUpdate.t(), Websocket.t()}
  @type guild_ban_add ::
          {:GUILD_BAN_ADD, GuildBanAdd.t(), Websocket.t()}
  @type guild_ban_remove ::
          {:GUILD_BAN_REMOVE, GuildBanRemove.t(), Websocket.t()}
  @type guild_create ::
          {:GUILD_CREATE, new_guild :: Remedy.Struct.Guild.t(), Websocket.t()}
  @type guild_available ::
          {:GUILD_AVAILABLE, new_guild :: Remedy.Struct.Guild.t(), Websocket.t()}
  @type guild_unavailable ::
          {:GUILD_UNAVAILABLE, unavailable_guild :: Remedy.Struct.Guild.UnavailableGuild.t(), Websocket.t()}
  @type guild_update ::
          {:GUILD_UPDATE, {old_guild :: Remedy.Struct.Guild.t(), new_guild :: Remedy.Struct.Guild.t()}, Websocket.t()}
  @type guild_delete ::
          {:GUILD_DELETE, {old_guild :: Remedy.Struct.Guild.t(), unavailable :: boolean}, Websocket.t()}
  @type guild_emojis_update ::
          {:GUILD_EMOJIS_UPDATE,
           {guild_id :: integer, old_emojis :: [Remedy.Struct.Emoji.t()], new_emojis :: [Remedy.Struct.Emoji.t()]},
           Websocket.t()}
  @type guild_integrations_update ::
          {:GUILD_INTEGRATIONS_UPDATE, GuildIntegrationsUpdate.t(), Websocket.t()}
  @type guild_member_add ::
          {:GUILD_MEMBER_ADD, {guild_id :: integer, new_member :: Remedy.Struct.Guild.Member.t()}, Websocket.t()}
  @type guild_members_chunk ::
          {:GUILD_MEMBERS_CHUNK, map, Websocket.t()}
  @type guild_member_remove ::
          {:GUILD_MEMBER_REMOVE, {guild_id :: integer, old_member :: Remedy.Struct.Guild.Member.t()}, Websocket.t()}

  @type guild_member_update ::
          {:GUILD_MEMBER_UPDATE,
           {guild_id :: integer, old_member :: Remedy.Struct.Guild.Member.t() | nil,
            new_member :: Remedy.Struct.Guild.Member.t()}, Websocket.t()}
  @type guild_role_create ::
          {:GUILD_ROLE_CREATE, {guild_id :: integer, new_role :: Remedy.Struct.Guild.Role.t()}, Websocket.t()}
  @type guild_role_delete ::
          {:GUILD_ROLE_DELETE, {guild_id :: integer, old_role :: Remedy.Struct.Guild.Role.t()}, Websocket.t()}

  @type guild_role_update ::
          {:GUILD_ROLE_UPDATE,
           {guild_id :: integer, old_role :: Remedy.Struct.Guild.Role.t() | nil,
            new_role :: Remedy.Struct.Guild.Role.t()}, Websocket.t()}
  @type message_create ::
          {:MESSAGE_CREATE, message :: Remedy.Struct.Message.t(), Websocket.t()}
  @type message_delete ::
          {:MESSAGE_DELETE, MessageDelete.t(), Websocket.t()}
  @type message_delete_bulk ::
          {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), Websocket.t()}
  @type message_update ::
          {:MESSAGE_UPDATE, updated_message :: Remedy.Struct.Message.t(), Websocket.t()}
  @type message_reaction_add ::
          {:MESSAGE_REACTION_ADD, MessageReactionAdd.t(), Websocket.t()}
  @type message_reaction_remove ::
          {:MESSAGE_REACTION_REMOVE, MessageReactionRemove.t(), Websocket.t()}
  @type message_reaction_remove_all ::
          {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), Websocket.t()}
  @type message_reaction_remove_emoji ::
          {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), Websocket.t()}
  @type message_ack :: {:MESSAGE_ACK, map, Websocket.t()}

  @type presence_update ::
          {:PRESENCE_UPDATE, {guild_id :: integer, old_presence :: map | nil, new_presence :: map}, Websocket.t()}
  @type ready ::
          {:READY, Ready.t(), Websocket.t()}
  @type resumed ::
          {:RESUMED, map, Websocket.t()}
  @type typing_start ::
          {:TYPING_START, TypingStart.t(), Websocket.t()}
  @type user_settings_update :: no_return

  @type user_update ::
          {:USER_UPDATE, {old_user :: Remedy.Struct.User.t() | nil, new_user :: Remedy.Struct.User.t()}, Websocket.t()}

  @type voice_ready :: {:VOICE_READY, VoiceReady.t(), VoiceWSState.t()}

  @type voice_speaking_update ::
          {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), VoiceWSState.t()}
  @type voice_state_update ::
          {:VOICE_STATE_UPDATE, VoiceState.t(), Websocket.t()}
  @type voice_server_update ::
          {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), Websocket.t()}
  @type webhooks_update ::
          {:WEBHOOKS_UPDATE, map, Websocket.t()}

  @type event ::
          channel_create
          | channel_delete
          | channel_update
          | channel_pins_ack
          | channel_pins_update
          | guild_ban_add
          | guild_ban_remove
          | guild_create
          | guild_available
          | guild_unavailable
          | guild_update
          | guild_delete
          | guild_emojis_update
          | guild_integrations_update
          | guild_member_add
          | guild_members_chunk
          | guild_member_remove
          | guild_member_update
          | guild_role_create
          | guild_role_delete
          | guild_role_update
          | message_create
          | message_delete
          | message_delete_bulk
          | message_update
          | message_reaction_add
          | message_reaction_remove
          | message_reaction_remove_all
          | message_ack
          | presence_update
          | ready
          | resumed
          | typing_start
          | user_settings_update
          | user_update
          | voice_ready
          | voice_speaking_update
          | voice_state_update
          | voice_server_update
          | webhooks_update

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
