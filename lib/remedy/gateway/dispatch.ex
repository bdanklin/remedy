defmodule Remedy.Shard.EventDispatch do
  require Logger

  @large_threshold 250

  def handle(socket) do
    if Application.get_env(:remedy, :log_full_events),
      do: Logger.debug(inspect(socket.payload.d, pretty: true))

    socket.payload.t
    |> handle_event(socket.payload.d, socket)
    |> format_event()
  end

  defp format_event(events) when is_list(events),
    do: for(event <- events, do: format_event(event))

  # Handles the case of not finding users in the user cache
  defp format_event({_name, :noop, _state}), do: :noop
  defp format_event({_name, event_info, _state} = event) when is_tuple(event_info), do: event
  defp format_event({name, event_info, state}), do: {name, event_info, state}
  defp format_event(:noop), do: :noop

  defp check_new_or_unavailable(guild_id) do
    case :ets.lookup(:unavailable_guilds, guild_id) do
      [] -> :GUILD_CREATE
      [_] -> :GUILD_AVAILABLE
    end
  end

  def handle_event(:CHANNEL_CREATE = event, p, state) do
    {event, ChannelCache.create(p), state}
  end

  def handle_event(:CHANNEL_DELETE = event, %{type: 1} = p, state) do
    {event, ChannelCache.delete(p.id), state}
  end

  def handle_event(:CHANNEL_DELETE = event, %{type: t} = p, state) when t in [0, 2] do
    {event, GuildCache.channel_delete(p.guild_id, p.id), state}
  end

  def handle_event(:CHANNEL_UPDATE = event, p, state) do
    {event, GuildCache.channel_update(p.guild_id, p), state}
  end

  def handle_event(:CHANNEL_DELETE, _p, _state) do
    :noop
  end

  def handle_event(:CHANNEL_PINS_ACK = event, p, state), do: {event, p, state}

  def handle_event(:CHANNEL_PINS_UPDATE = event, p, state) do
    {event, ChannelPinsUpdate.to_struct(p), state}
  end

  def handle_event(:GUILD_BAN_ADD = event, p, state) do
    {event, GuildBanAdd.to_struct(p), state}
  end

  def handle_event(:GUILD_BAN_REMOVE = event, p, state) do
    {event, GuildBanRemove.to_struct(p), state}
  end

  # def handle_event(:GUILD_CREATE, %{unavailable: true} = guild, state) do
  #   :ets.insert(:unavailable_guilds, {guild.id, guild})
  #   {:GUILD_UNAVAILABLE, UnavailableGuild.to_struct(guild), state}
  # end

  def handle_event(:GUILD_CREATE, p, state) do
    # Ensures every channel will have an associated guild_id
    channels_with_guild_id =
      p.channels
      |> Enum.map(fn channel -> Map.put(channel, :guild_id, p.id) end)

    guild = %{p | channels: channels_with_guild_id}

    guild.members
    |> Enum.each(fn member -> UserCache.create(member.user) end)

    :ets.insert(:guild_shard_map, {guild.id, state.shard})

    Enum.each(guild.channels, fn channel ->
      :ets.insert(:channel_guild_map, {channel.id, guild.id})
    end)

    has_members = Intents.has_intent?(:guild_members)
    has_presences = Intents.has_intent?(:guild_presences)

    intents_should_request? = has_members and not has_presences
    large_server? = guild.member_count >= @large_threshold

    should_request? = large_server? or intents_should_request?

    if should_request? and Application.get_env(:remedy, :request_guild_members, false) do
      Session.request_guild_members(state.conn_pid, guild.id)
    end

    {presences, guild} = Map.pop(guild, :presences, [])
    PresenceCache.bulk_create(guild.id, presences)

    guild = Util.cast(guild, {:struct, Guild})

    true = GuildCache.create(guild)
    {check_new_or_unavailable(guild.id), guild, state}
  end

  def handle_event(:GUILD_UPDATE = event, p, state),
    do: {event, GuildCache.update(p), state}

  def handle_event(:GUILD_DELETE = event, p, state) do
    :ets.delete(:guild_shard_map, p.id)
    {event, {GuildCache.delete(p.id), Map.get(p, :unavailable, false)}, state}
  end

  def handle_event(:GUILD_EMOJIS_UPDATE = event, p, state),
    do: {event, GuildCache.emoji_update(p.guild_id, p.emojis), state}

  def handle_event(:GUILD_INTEGRATIONS_UPDATE = event, p, state) do
    {event, GuildIntegrationsUpdate.to_struct(p), state}
  end

  def handle_event(:GUILD_MEMBER_ADD = event, p, state) do
    UserCache.create(p.user)
    {event, GuildCache.member_add(p.guild_id, p), state}
  end

  def handle_event(:GUILD_MEMBERS_CHUNK = event, p, state) do
    UserCache.bulk_create(p.members)
    GuildCache.member_chunk(p.guild_id, p.members)

    # note: not casted at the moment, deemed mostly internal
    {event, p, state}
  end

  def handle_event(:GUILD_MEMBER_REMOVE = event, p, state),
    do: {event, GuildCache.member_remove(p.guild_id, p.user), state}

  def handle_event(:GUILD_MEMBER_UPDATE = event, %{guild_id: guild_id} = p, state) do
    {event, GuildCache.member_update(guild_id, p), state}
  end

  def handle_event(:GUILD_ROLE_CREATE = event, p, state),
    do: {event, GuildCache.role_create(p.guild_id, p.role), state}

  def handle_event(:GUILD_ROLE_DELETE = event, p, state),
    do: {event, GuildCache.role_delete(p.guild_id, p.role_id), state}

  def handle_event(:GUILD_ROLE_UPDATE = event, %{guild_id: guild_id} = p, state),
    do: {event, GuildCache.role_update(guild_id, p.role), state}

  def handle_event(:INVITE_CREATE = event, p, state),
    do: {event, InviteCreate.to_struct(p), state}

  def handle_event(:INVITE_DELETE = event, p, state),
    do: {event, InviteDelete.to_struct(p), state}

  def handle_event(:MESSAGE_CREATE = event, p, state), do: {event, Message.to_struct(p), state}

  def handle_event(:MESSAGE_DELETE = event, p, state),
    do: {event, MessageDelete.to_struct(p), state}

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

### Genstage stuff below here. Don't worry about it too much 🦆🦆🦆🦆
defmodule Remedy.Gateway.EventBroadcaster do
  @moduledoc false

  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  def digest(event) do
    GenStage.cast(__MODULE__, {:notify, event})
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

  alias Remedy.Shard.Dispatch
  alias Remedy.Gateway.EventBroadcaster

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
