defmodule Remedy.Gateway.Dispatch do
  @moduledoc """
  Gateway Dispatching
  """
  @type payload :: any()
  @type socket :: Websocket.t()
  @type event :: atom()
  @callback handle({event, payload, socket}) :: {event, payload, socket}

  @dispatch_events [
    :CHANNEL_CREATE,
    :CHANNEL_DELETE,
    :CHANNEL_PINTS_UPDATE,
    :CHANNEL_UPDATE,
    :GUILD_BAN_ADD,
    :GUILD_BAN_REMOVE,
    :GUILD_CREATE,
    :GUILD_DELETE,
    :GUILD_EMOJIS_UPDATE,
    :GUILD_INTEGRATIONS_UPDATE,
    :GUILD_MEMBVER_ADD,
    :GUILD_MEMBER_REMOVE,
    :GUILD_MEMBER_UPDATE,
    :GUILD_MEMBERS_CHUNK,
    :GUILD_ROLE_CREATE,
    :GUILD_ROLE_DELETE,
    :GUILD_ROLE_UPDATE,
    :GUILD_STICKERS_UPDATE,
    :GUILD_UPDATE,
    :INTEGRATION_CREATE,
    :INTEGRATION_DELETE,
    :INTEGRATION_UPDATE,
    :INTERACTION_CREATE,
    :INVITE_CREATE,
    :INVITE_DELETE,
    :MESSAGE_CREATE,
    :MESSAGE_DELETE_BULK,
    :MESSAGE_DELETE,
    :MESSAGE_REACTION_ADD,
    :MESSAGE_REACTION_REMOVE_ALL,
    :MESSAGE_REACTION_REMOVE_EMOJI,
    :MESSAGE_REACTION_REMOVE,
    :MESSAGE_UPDATE,
    :PRESENCE_UPDATE,
    :READY,
    :RESUMED,
    :SPEAKING_UPDATE,
    :STAGE_INSTANCE_CREATE,
    :STAGE_INSTANCE_DELETE,
    :STAGE_INSTANCE_UPDATE,
    :THREAD_CREATE,
    :THREAD_DELETE,
    :THREAD_LIST_SYNC,
    :THREAD_MEMBER_UPDATE,
    :THREAD_MEMBERS_UPDATE,
    :THREAD_UPDATE,
    :TYPING_START,
    :USER_UPDATE,
    :VOICE_SERVER_UPDATE,
    :VOICE_STATE_UPDATE,
    :WEBHOOKS_UPDATE
  ]

  require Logger

  def handle({event, payload, socket} = dispatch) do
    Logger.debug("#{event}")

    if Application.get_env(:remedy, :log_everything, false),
      do: Logger.debug("#{inspect(event)}, #{inspect(payload)}")

    case event in @dispatch_events do
      true ->
        mod_from_dispatch(event).handle(dispatch)

      false ->
        Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{event}, #{inspect(payload)}")
        {event, payload, socket}
    end
  end

  defp mod_from_dispatch(k) do
    to_string(k)
    |> String.downcase()
    |> Recase.to_pascal()
    |> List.wrap()
    |> Module.concat()
  end

  def handle_event(:WEBHOOKS_UPDATE = event, p, state), do: {event, p, state}
end

### 🦆🦆🦆🦆 Genstage stuff below here. Don't worry about it too much 🦆🦆🦆🦆

defmodule Remedy.Gateway.EventBroadcaster do
  @moduledoc false

  use GenStage

  require Logger

  @doc """

  """
  def digest(event) do
    GenStage.cast(__MODULE__, {:notify, event})
  end

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  def handle_cast({:notify, event}, {queue, demand}) do
    dispatch_events(:queue.in(event, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, demand + incoming_demand, [])
  end

  def dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand, {{:value, payload}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [payload | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}, :hibernate}
    end
  end
end

defmodule Remedy.Gateway.EventBuffer do
  @moduledoc false

  use GenStage

  alias Remedy.Gateway.{Dispatch, EventBroadcaster}

  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, [], subscribe_to: [EventBroadcaster]}
  end

  def handle_events(events, _from, state) do
    {:noreply,
     events
     |> dispatch(), state, :hibernate}
  end

  defp dispatch(events) do
    events
    |> Enum.map(&Dispatch.handle/1)
    |> List.flatten()
    |> Enum.filter(fn event -> event != :noop end)
  end
end
