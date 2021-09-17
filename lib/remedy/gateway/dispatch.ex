defmodule Remedy.Gateway.Dispatch do
  @moduledoc """
  Gateway Dispatching
  """
  @type payload :: any()
  @type socket :: Websocket.t()
  @type event :: atom()

  @callback handle({event, payload, socket}) :: {event, payload, socket}

  require Logger

  def handle({event, payload, _socket} = dispatch) do
    Logger.debug("#{event}")

    if Application.get_env(:remedy, :log_everything, false),
      do: Logger.debug("#{inspect(event)}, #{inspect(payload)}")

    mod_from_dispatch(event).handle(dispatch)
  end

  defp mod_from_dispatch(k) do
    to_string(k)
    |> String.downcase()
    |> Recase.to_pascal()
    |> List.wrap()
    |> Module.concat()
  end

  def handle_event(:MESSAGE_DELETE_BULK = event, p, state),
    do: {event, MessageDeleteBulk.to_struct(p), state}

  def handle_event(:MESSAGE_UPDATE = event, p, state), do: {event, Message.to_struct(p), state}

  def handle_event(:MESSAGE_REACTION_ADD = event, p, state) do
    {event, MessageReactionAdd.to_struct(p), state}
  end

  def handle_event(:MESSAGE_REACTION_REMOVE = event, p, state) do
    {event, MessageReactionRemove.to_struct(p), state}
  end

  def handle_event(:MESSAGE_REACTION_REMOVE_ALL = event, p, state) do
    {event, MessageReactionRemoveAll.to_struct(p), state}
  end

  def handle_event(:MESSAGE_REACTION_REMOVE_EMOJI = event, p, state) do
    {event, MessageReactionRemoveEmoji.to_struct(p), state}
  end

  def handle_event(:MESSAGE_ACK = event, p, state), do: {event, p, state}

  def handle_event(:PRESENCE_UPDATE = event, p, state) do
    [
      {event, PresenceCache.update(p), state}
      | [handle_event(:USER_UPDATE, p.user, state)]
    ]
  end

  def handle_event(:READY = event, p, state) do
    p.private_channels
    |> Enum.each(fn dm_channel -> ChannelCache.create(dm_channel) end)

    ready_guilds =
      p.guilds
      |> Enum.map(fn guild -> handle_event(:GUILD_CREATE, guild, state) end)

    current_user = Util.cast(p.user, {:struct, User})
    Bot.put(current_user)

    [{event, p, state}] ++ ready_guilds
  end

  def handle_event(:RESUMED = event, p, state), do: {event, p, state}

  def handle_event(:TYPING_START = event, p, state) do
    {event, TypingStart.to_struct(p), state}
  end

  def handle_event(:USER_SETTINGS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:USER_UPDATE = event, p, state) do
    if Bot.get().id === p.id do
      Bot.update(p)
    end

    {event, UserCache.update(p), state}
  end

  def handle_event(:VOICE_READY = event, p, state),
    do: {event, VoiceReady.to_struct(p), state}

  def handle_event(:VOICE_SPEAKING_UPDATE = event, p, state),
    do: {event, SpeakingUpdate.to_struct(p), state}

  def handle_event(:VOICE_STATE_UPDATE = event, p, state) do
    if Bot.get().id === p.user_id do
      if p.channel_id do
        # Joining Channel
        voice = Voice.get_voice(p.guild_id)

        cond do
          # Not yet in a channel:
          is_nil(voice) or is_nil(voice.session) ->
            Voice.update_voice(p.guild_id,
              channel_id: p.channel_id,
              session: p.session_id,
              self_mute: p.self_mute,
              self_deaf: p.self_deaf
            )

          # Already in different channel:
          voice.channel_id != p.channel_id and is_pid(voice.session_pid) ->
            v_ws = VoiceSession.get_ws_state(voice.session_pid)
            # On the off-chance that we receive Voice Server Update first:
            {new_token, new_gateway} =
              if voice.token == v_ws.token do
                # Need to reset
                {nil, nil}
              else
                # Already updated
                {voice.token, voice.gateway}
              end

            Voice.remove_voice(p.guild_id)

            Voice.update_voice(p.guild_id,
              channel_id: p.channel_id,
              session: p.session_id,
              self_mute: p.self_mute,
              self_deaf: p.self_deaf,
              token: new_token,
              gateway: new_gateway
            )

          # Already in this channel:
          true ->
            Voice.update_voice(p.guild_id)
        end
      else
        # Leaving Channel:
        Voice.remove_voice(p.guild_id)
      end
    end

    GuildCache.voice_state_update(p.guild_id, p)
    {event, VoiceState.to_struct(p), state}
  end

  def handle_event(:VOICE_SERVER_UPDATE = event, p, state) do
    Voice.update_voice(p.guild_id,
      token: p.token,
      gateway: p.endpoint
    )

    {event, VoiceServerUpdate.to_struct(p), state}
  end

  def handle_event(:WEBHOOKS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:INTERACTION_CREATE = event, p, state) do
    {event, Interaction.to_struct(p), state}
  end

  def handle_event(event, p, state) do
    Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{event}, #{inspect(p)}")
    {event, p, state}
  end
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
