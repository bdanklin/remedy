defmodule Remedy.Status.Gateway do
  ### Add gateway opcode functions etc etc
  ### > https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
  ### > https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes

  #   @opcodes [
  #   {0,	  DISPATCH,                    "DISPATCH",	["Receive"],	"An event was dispatched."},
  #   {1,	  HEARTBEAT,                   "HEARTBEAT",           	["Send", "Receive"],	"Fired periodically by the client to keep the connection alive."},
  #   {2,	  IDENTIFY,                    "IDENTIFY",            	["Send"],	"Starts a new session during the initial handshake."},
  #   {3,	  PRESENCE_UPDATE,             "PRESENCE_UPDATE",       ["Send"],	"Update the client's presence."},
  #   {4,	  VOICE_STATE_UPDATE,          "VOICE_STATE_UPDATE",  	["Send"],	"Used to join/leave or move between voice channels."},
  #   {6,	  RESUME,                      "RESUME",              	["Send"],	"Resume a previous session that was disconnected."},
  #   {7,	  RECONNECT,                   "RECONNECT",           	["Receive"],	"You should attempt to reconnect and resume immediately."},
  #   {8,	  REQUEST_GUILD_MEMBERS,       "REQUEST_GUILD_MEMBERS",	["Send"],	"Request information about offline guild members in a large guild."},
  #   {9,	  INVALID_SESSION,             "INVALID_SESSION",     	["Receive"],	"The session has been invalidated. You should reconnect and identify/resume accordingly."},
  #   {10,  HELLO,                       "HELLO",               	["Receive"],	"Sent immediately after connecting, contains the heartbeat_interval to use."},
  #   {11,  HEARTBEAT_ACK,               "HEARTBEAT_ACK",       	["Receive"],	"Sent in response to receiving a heartbeat to acknowledge that it has been received."},
  #   ]

  #   @op %{
  #     "DISPATCH" => 0,
  #     "HEARTBEAT" => 1,
  #     "IDENTIFY" => 2,
  #     "STATUS_UPDATE" => 3,
  #     "VOICE_STATUS_UPDATE" => 4,
  #     "VOICE_SERVER_PING" => 5,
  #     "RESUME" => 6,
  #     "RECONNECT" => 7,
  #     "REQUEST_GUILD_MEMBERS" => 8,
  #     "INVALID_SESSION" => 9,
  #     "HELLO" => 10,
  #     "HEARTBEAT_ACK" => 11,
  #     "SYNC_GUILD" => 12,
  #     "SYNC_CALL" => 13
  #   }
end
