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
          {:CHANNEL_CREATE, Channel.t(), WSState.t()}
          | {:CHANNEL_DELETE, Channel.t(), WSState.t()}
          | {:CHANNEL_PINS_UPDATE, ChannelPinsUpdate.t(), WSState.t()}
          | {:CHANNEL_UPDATE, Channel.t(), WSState.t()}
          | {:GUILD_AVAILABLE, Guild.t(), WSState.t()}
          | {:GUILD_BAN_ADD, GuildBanAdd.t(), WSState.t()}
          | {:GUILD_BAN_REMOVE, GuildBanRemove.t(), WSState.t()}
          | {:GUILD_CREATE, Guild.t(), WSState.t()}
          | {:GUILD_DELETE, Guild.t(), WSState.t()}
          | {:GUILD_EMOJIS_UPDATE, [Emoji.t()], WSState.t()}
          | {:GUILD_INTEGRATIONS_UPDATE, GuildIntegrationsUpdate.t(), WSState.t()}
          | {:GUILD_MEMBER_ADD, Member.t(), WSState.t()}
          | {:GUILD_MEMBER_REMOVE, Member.t(), WSState.t()}
          | {:GUILD_MEMBER_UPDATE, Member.t(), Member.t(), WSState.t()}
          | {:GUILD_MEMBERS_CHUNK, map(), WSState.t()}
          | {:GUILD_ROLE_CREATE, Role.t(), WSState.t()}
          | {:GUILD_ROLE_DELETE, Role.t(), WSState.t()}
          | {:GUILD_ROLE_UPDATE, Role.t(), WSState.t()}
          | {:GUILD_UNAVAILABLE, UnavailableGuild.t(), WSState.t()}
          | {:GUILD_UPDATE, Guild.t(), WSState.t()}
          | {:MESSAGE_ACK, map, WSState.t()}
          | {:MESSAGE_CREATE, Message.t(), WSState.t()}
          | {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), WSState.t()}
          | {:MESSAGE_DELETE, MessageDelete.t(), WSState.t()}
          | {:MESSAGE_REACTION_ADD, MessageReactionAdd.t(), WSState.t()}
          | {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), WSState.t()}
          | {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), WSState.t()}
          | {:MESSAGE_REACTION_REMOVE, MessageReactionRemove.t(), WSState.t()}
          | {:MESSAGE_UPDATE, Message.t(), WSState.t()}
          | {:PRESENCE_UPDATE, Presence.t(), WSState.t()}
          | {:READY, Ready.t(), WSState.t()}
          | {:RESUMED, map, WSState.t()}
          | {:TYPING_START, TypingStart.t(), WSState.t()}
          | {:USER_UPDATE, User.t(), WSState.t()}
          | {:VOICE_READY, VoiceReady.t(), VoiceWSState.t()}
          | {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), WSState.t()}
          | {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), VoiceWSState.t()}
          | {:VOICE_STATE_UPDATE, VoiceState.t(), WSState.t()}
          | {:WEBHOOKS_UPDATE, map, WSState.t()}

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
