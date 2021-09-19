# def handle_event(:VOICE_READY = event, p, state),
#   do: {event, VoiceReady.to_struct(p), state}

# def handle_event(:VOICE_SPEAKING_UPDATE = event, p, state),
#   do: {event, SpeakingUpdate.to_struct(p), state}

# def handle_event(:VOICE_STATE_UPDATE = event, p, state) do
#   if Cache.bot().id === p.user_id do
#     if p.channel_id do
#       # Joining Channel
#       voice = Voice.get_voice(p.guild_id)

#       cond do
#         # Not yet in a channel:
#         is_nil(voice) or is_nil(voice.session) ->
#           Voice.update_voice(p.guild_id,
#             channel_id: p.channel_id,
#             session: p.session_id,
#             self_mute: p.self_mute,
#             self_deaf: p.self_deaf
#           )

#         # Already in different channel:
#         voice.channel_id != p.channel_id and is_pid(voice.session_pid) ->
#           v_ws = VoiceSession.get_ws_state(voice.session_pid)
#           # On the off-chance that we receive Voice Server Update first:
#           {new_token, new_gateway} =
#             if voice.token == v_ws.token do
#               # Need to reset
#               {nil, nil}
#             else
#               # Already updated
#               {voice.token, voice.gateway}
#             end

#           Voice.remove_voice(p.guild_id)

#           Voice.update_voice(p.guild_id,
#             channel_id: p.channel_id,
#             session: p.session_id,
#             self_mute: p.self_mute,
#             self_deaf: p.self_deaf,
#             token: new_token,
#             gateway: new_gateway
#           )

#         # Already in this channel:
#         true ->
#           Voice.update_voice(p.guild_id)
#       end
#     else
#       # Leaving Channel:
#       Voice.remove_voice(p.guild_id)
#     end
#   end

#   GuildCache.voice_state_update(p.guild_id, p)
#   {event, VoiceState.to_struct(p), state}
# end
# def handle_event(:VOICE_SERVER_UPDATE = event, p, state) do
#   Voice.update_voice(p.guild_id,
#     token: p.token,
#     gateway: p.endpoint
#   )

#   {event, VoiceServerUpdate.to_struct(p), state}
# end
