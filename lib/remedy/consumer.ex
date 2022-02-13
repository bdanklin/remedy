defmodule Remedy.Consumer do
  @moduledoc """
  Consumer process for gateway event handling.

  You have two options for handling events. You can create a consumer module through the behaviour described in this module, which implements `c:handle_event/1`. Or you can create your own GenStage or Broadway pipeline to process the events. Details of each of these methods are described below. Events will be buffered up to 10,000 inside the `Remedy.Consumer.Producer` process waiting for a subscriber to connect. If you are using the Consumer Module method, you will subscribe immediately. If you are implementing your own GenStage or Broadway pipeline, you will have to start your module and subscribe yourself.

  ## Consumer Module

  The simplest consumer implementation is to use the Consumer behaviour by adding `use Remedy.Consumer` to your module.

  This will handle all of the supervision and set up for you. all you need to implement is the `c:handle_event/1` callback for all the events you wish to consume. Using this method will start your consumer under the Remedy supervision tree and you are not required to start it yourself.

  This method is used to implement the standard event logging module, which looks something like this internally.

      defmodule Remedy.Consumer.LumberJack do
        use Remedy.Consumer

        def handle_event(event, payload, _meta) do
          Logger.debug("\#{inspect(event)} \#{inspect(payload)}")
        end

      end

  Internally, the events are run in a `ConsumerSupervisor` which is configured to run `System.schedulers/0` number of tasks concurrently. The tasks are wrapped in a `try rescue` block to ensure the consumer will never be taken down. If you start seeing `CONSUMER_ERROR` in your logs it means there is an error with your callback implementation and your callbacks are being rescued. There is no retry logic while using this method and the event is lost.

  ## Genstage

  If you wish to implement a custom `GenStage` pipeline you can simply subscribe to `Remedy.Consumer.Producer` inside your init callback. The other implementation details are the concern of the readers individual situation, such as how the module will be started and supervised.

      defmodule MyApp.PipelineProducer do
        @moduledoc false
        use GenStage

        @impl GenStage
        def init(_opts) do
          opts = [
            dispatcher: GenStage.DemandDispatcher,
            subscribe_to: [Remedy.Consumer.Producer]
          ]
          {:producer_consumer, :state, opts}
        end

        @impl GenStage
        def handle_events(events, _from, state) do
          {:noreply, [events], state, :hibernate}
        end

        @impl GenStage
        def handle_demand(_incoming_demand, state) do
          {:noreply, [], state, :hibernate}
        end
      end

  ## Broadway

  To implement a `Broadway` pipeline you should first create a `:producer_consumer` per the example above. You can then use that producer as your as your `Broadway` producer. Following that you just need to implement the callbacks specific to your pipeline. Note that because Remedy uses `Broadway` internally, there is no need to include it as a dependency.

      defmodule MyApp.Pipeline do
        use Broadway
        def start_link(_opts) do
          Broadway.start_link(__MODULE__,
            name: __MODULE__,
            producer: [
              module: {PipelineProducer, []},
              concurrency: 1
            ],
            processors: [
              default: [concurrency: 10]
            ],
            batchers: [
              channel_create: [concurrency: 100],
              default: [concurrency: 10],
              unhandled: [concurrency: 1]
            ]
          )
        end

        def handle_message(_, %{data: %{event: :CHANNEL_CREATE}}} = message, _) do
          message
          |> Broadway.Message.put_batcher(:CHANNEL_CREATE)
        end

        # Other Callbacks
      end

  """

  use Remedy.Schema, :schema_alias

  alias Remedy.Consumer.Metadata

  @doc """

  """
  @callback handle_event(term) :: term() | :ok | :noop

  @typedoc """
  Received when a channel is created.
  """
  #  [Read More](https://discord.com/developers/docs/topics/gateway#channel-create)
  @type channel_create :: {:CHANNEL_CREATE, Channel.t(), Metadata.t()}

  @typedoc """
  Received when a channel is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#channel-update)
  @type channel_update :: {:CHANNEL_UPDATE, Channel.t(), Metadata.t()}

  @typedoc """
  Received when a channel is deleted.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#channel-delete)
  @type channel_delete :: {:CHANNEL_DELETE, Channel.t(), Metadata.t()}

  @typedoc """
  Received when a message is pinned or unpinned.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#channel-pins-update)
  @type channel_pins_update :: {:CHANNEL_UPDATE, Channel.t(), Metadata.t()}

  # TODO: prob unused
  @type guild_available :: {:GUILD_AVAILABLE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when a user is banned from a guild.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-ban-add)
  @type guild_ban_add :: {:GUILD_BAN_ADD, Ban.t(), Metadata.t()}

  @typedoc """
  Received when a user is unbanned from a guild.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-ban-remove)
  @type guild_ban_remove :: {:GUILD_BAN_REMOVE, Ban.t(), Metadata.t()}

  @typedoc """
  Received when joining a new guild.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-create)
  @type guild_create :: {:GUILD_CREATE, Guild.t(), Metadata.t()}

  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-delete)
  @type guild_delete :: {:GUILD_DELETE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when a guild is unavailable due to an outage.
  """
  @type guild_unavailable :: {:GUILD_UNAVAILABLE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when the bot leaves a guild.
  """
  @type guild_leave :: {:GUILD_LEAVE, Guild.t(), Metadata.t()}

  @typedoc """
  Recieved when the bot is kicked from a guild.
  """
  @type guild_kicked :: {:GUILD_KICKED, Guild.t(), Metadata.t()}

  @typedoc """
  Received when a guild's emojis have been updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-emojis-update)
  @type guild_emojis_update :: {:GUILD_EMOJIS_UPDATE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when a guild integration is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-integrations-update)
  @type guild_integrations_update :: {:GUILD_INTEGRATIONS_UPDATE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when a new user joins a guild.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-add)
  @type guild_member_add :: {:GUILD_MEMBER_ADD, Member.t(), Metadata.t()}

  @typedoc """
  Received when a used is removed from a guild.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-remove)
  @type guild_member_kicked :: {:GUILD_MEMBER_REMOVE, Member.t(), Metadata.t()}

  @typedoc """
  Received when a guild member is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-member-update)
  @type guild_member_update :: {:GUILD_MEMBER_UPDATE, Member.t(), Metadata.t()}

  @typedoc """
  Received when a guild role is created.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-create)
  @type guild_role_create :: {:GUILD_ROLE_CREATE, Role.t(), Metadata.t()}

  @typedoc """
  Received when a guild role is deleted.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-delete)
  @type guild_role_delete :: {:GUILD_ROLE_DELETE, Role.t(), Metadata.t()}

  @typedoc """
  Received when a guild role is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-role-update)
  @type guild_role_update :: {:GUILD_ROLE_UPDATE, Role.t(), Metadata.t()}

  @typedoc """
  Receivedent when a guild is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#guild-update)
  @type guild_update :: {:GUILD_UPDATE, Guild.t(), Metadata.t()}

  @typedoc """
  Received when an integration is created.
  """
  #   [Read More](https://discord.com/developers/docs/topics/gateway#integration-create)
  @type integration_create :: {:INTEGRATION_CREATE, Integration.t(), Metadata.t()}

  @typedoc """
  Received when an integration is updated.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#integration-update)
  @type integration_update :: {:INTEGRATION_UPDATE, Integration.t(), Metadata.t()}

  @typedoc """
  Received when an integration is deleted.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#integration-delete)
  @type integration_delete :: {:INTEGRATION_DELETE, Integration.t(), Metadata.t()}

  @typedoc """
  Received when a user triggers an `Application Command`
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#interaction-create)
  @type interaction_create :: {:INTERACTION_CREATE, Interaction.t(), Metadata.t()}

  @typedoc """
  Received when a message is created.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-create)
  @type message_create :: {:MESSAGE_CREATE, Message.t(), Metadata.t()}

  @typedoc """
  Received when multiple messages are deleted at once.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-delete-bulk)
  @type message_delete_bulk :: {:MESSAGE_DELETE_BULK, MessageDeleteBulk.t(), Metadata.t()}

  @typedoc """
  Received when a messgae is deleted.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-delete)
  @type message_delete :: {:MESSAGE_DELETE, Message.t(), Metadata.t()}

  @typedoc """
  Received when a user adds a reaction to a message.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-add)
  @type reaction_add :: {:REACTION_ADD, Reaction.t(), Metadata.t()}

  @typedoc false
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove)
  @type message_reaction_remove_all :: {:MESSAGE_REACTION_REMOVE_ALL, MessageReactionRemoveAll.t(), Metadata.t()}

  @typedoc false
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove-emoji)
  @type message_reaction_remove_emoji :: {:MESSAGE_REACTION_REMOVE_EMOJI, MessageReactionRemoveEmoji.t(), Metadata.t()}

  @typedoc """
  Received when a user removes a reaction from a message.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#message-reaction-remove)
  @type reaction_remove :: {:REACTION_REMOVE, Reaction.t(), Metadata.t()}

  @typedoc """
  Sent when a message is updated.
  """
  #   [Read More](https://discord.com/developers/docs/topics/gateway#message-update)
  @type message_update :: {:MESSAGE_UPDATE, Message.t(), Metadata.t()}

  @typedoc """
  Received when a user's presence or info is updated.
  """
  @type presence_update :: {:PRESENCE_UPDATE, User.t(), Metadata.t()}

  @typedoc """
  Received when the bot is online.
  """
  @type ready :: {:READY, Ready.t(), Metadata.t()}

  @typedoc """
  Sent when a thread is created or when the user is added to a thread.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#channel-delete)
  @type thread_create :: {:THREAD_CREATE, Thread.t(), Metadata.t()}

  @typedoc """
  Sent when a thread relevant to the current user is deleted.
  """
  # [Read More](https://discord.com/developers/docs/topics/gateway#thread-delete)
  @type thread_delete :: {:THREAD_DELETE, Thread.t(), Metadata.t()}

  @typedoc false
  # [Read More](https://discord.com/developers/docs/topics/gateway#thread-list-sync-thread-list-sync-event-fields)
  @type thread_list_sync :: {:THREAD_LIST_SYNC, ThreadListSync.t(), Metadata.t()}

  @typedoc """
  Received when the thread member object for the current user is updated.
  """
  @type thread_member_update :: {:THREAD_MEMBER_UPDATE, ThreadMember.t(), Metadata.t()}

  @typedoc """
  Received when anyone is added to or removed from a thread.
  """
  @type thread_members_update :: {:THREAD_MEMBERS_UPDATE, ThreadMember.t(), Metadata.t()}

  @typedoc """
  Received when a thread is updated.
  """
  @type thread_update :: {:THREAD_UPDATE, Thread.t(), Metadata.t()}

  @typedoc """
  Received when a user begins typing in a channel.
  """
  @type typing_start :: {:TYPING_START, TypingStart.t(), Metadata.t()}

  @typedoc """
  Received when a user is updated.
  """
  @type user_update :: {:USER_UPDATE, User.t(), Metadata.t()}

  @typedoc """
  Received when a webhook is updated.
  """
  @type webhooks_update :: {:WEBHOOKS_UPDATE, WebhooksUpdate.t(), Metadata.t()}

  @typedoc """
  Received when a user's voice state is updated.
  """
  @type voice_state_update :: {:VOICE_STATE_UPDATE, VoiceState.t(), Metadata.t()}

  @typedoc """
  Received when a webhook is updated.
  """
  @type voice_server_update :: {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t(), Metadata.t()}

  @typedoc """
  Received when a webhook is updated.
  """
  @type voice_ready :: {:VOICE_READY, VoiceReady.t(), Metadata.t()}

  @typedoc """
  Received when a webhook is updated.
  """
  @type voice_speaking_update :: {:VOICE_SPEAKING_UPDATE, SpeakingUpdate.t(), Metadata.t()}

  @optional_callbacks [handle_event: 1]

  use Supervisor
  require Logger
  alias Remedy.Consumer.Producer
  alias Remedy.Consumer.LumberJack
  @doc false
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def child_spec(init_arg) do
    default = %{id: __MODULE__, start: {__MODULE__, :start_link, [init_arg]}, type: :supervisor}
    Supervisor.child_spec(default, [])
  end

  @doc false
  def init(args) do
    lumberjack = if Keyword.get(args, :env) == :dev, do: [{LumberJack, []}], else: []
    children = [Producer] ++ lumberjack
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc false
  def start_link(mod, {event, payload, socket}) do
    Task.start_link(fn ->
      try do
        mod.handle_event({event, payload}, handle_socket(socket))
      rescue
        _ -> Logger.error("CONSUMER CRASHED WHEN HANDLING #{inspect(event)} #{inspect(payload)}")
      end
    end)
  end

  # TODO: impl
  @doc false
  def handle_socket(%Remedy.Gateway.Session.WSState{}) do
    & &1
  end

  def handle_socket(%Remedy.Voice.Session.WSState{}) do
    & &1
  end

  defmacro __using__(_opts) do
    quote do
      use ConsumerSupervisor
      alias Remedy.Consumer
      @behaviour Consumer

      def start_link(arg) do
        ConsumerSupervisor.start_link(__MODULE__, arg)
      end

      def init(_arg) do
        ConsumerSupervisor.init(
          [%{id: Consumer, start: {Consumer, :start_link, [__MODULE__]}, restart: :transient}],
          strategy: :one_for_one,
          subscribe_to: [{Producer, max_demand: System.schedulers() * 4}]
        )
      end

      @before_compile Consumer
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def handle_event({_event, _payload}, _meta) do
        :noop
      end
    end
  end
end
