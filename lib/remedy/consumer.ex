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
  import Remedy.ModelHelpers

  @callback handle_event(event) :: any

  @type event ::
          {:CHANNEL_CREATE, Channel.t(), Websocket.t()}
          | {:CHANNEL_DELETE, Channel.t(), Websocket.t()}
          | {:CHANNEL_PINS_UPDATE, ChannelPinsUpdate.t(), Websocket.t()}
          | {:CHANNEL_UPDATE, Channel.t(), Websocket.t()}
          | {:GUILD_AVAILABLE, Guild.t(), Websocket.t()}
          | {:GUILD_BAN_ADD, GuildBanAdd.t(), Websocket.t()}
          | {:GUILD_BAN_REMOVE, GuildBanRemove.t(), Websocket.t()}
          | {:GUILD_CREATE, Guild.t(), Websocket.t()}
          | {:GUILD_DELETE, Guild.t(), Websocket.t()}
          | {:GUILD_EMOJIS_UPDATE, [Emoji.t()], Websocket.t()}
          | {:GUILD_INTEGRATIONS_UPDATE, GuildIntegrationsUpdate.t(), Websocket.t()}
          | {:GUILD_MEMBER_ADD, Member.t(), Websocket.t()}
          | {:GUILD_MEMBER_REMOVE, Member.t(), Websocket.t()}
          | {:GUILD_MEMBER_UPDATE, Member.t(), Member.t(), Websocket.t()}
          | {:GUILD_MEMBERS_CHUNK, map(), Websocket.t()}
          | {:GUILD_ROLE_CREATE, Role.t(), Websocket.t()}
          | {:GUILD_ROLE_DELETE, Role.t(), Websocket.t()}
          | {:GUILD_ROLE_UPDATE, Role.t(), Websocket.t()}
          | {:GUILD_UNAVAILABLE, UnavailableGuild.t(), Websocket.t()}
          | {:GUILD_UPDATE, Guild.t(), Websocket.t()}
          | {:MESSAGE_ACK, map, Websocket.t()}
          | {:MESSAGE_CREATE, Message.t(), Websocket.t()}
          | {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), Websocket.t()}
          | {:MESSAGE_DELETE, MessageDelete.t(), Websocket.t()}
          | {:MESSAGE_REACTION_ADD, MessageReactionAdd.t(), Websocket.t()}
          | {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), Websocket.t()}
          | {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), Websocket.t()}
          | {:MESSAGE_REACTION_REMOVE, MessageReactionRemove.t(), Websocket.t()}
          | {:MESSAGE_UPDATE, Message.t(), Websocket.t()}
          | {:PRESENCE_UPDATE, Presence.t(), Websocket.t()}
          | {:READY, Ready.t(), Websocket.t()}
          | {:RESUMED, map, Websocket.t()}
          | {:TYPING_START, TypingStart.t(), Websocket.t()}
          | {:USER_UPDATE, User.t(), Websocket.t()}
          | {:VOICE_READY, VoiceReady.t(), VoiceWSState.t()}
          | {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), Websocket.t()}
          | {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), VoiceWSState.t()}
          | {:VOICE_STATE_UPDATE, VoiceState.t(), Websocket.t()}
          | {:WEBHOOKS_UPDATE, map, Websocket.t()}

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
