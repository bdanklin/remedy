defmodule Remedy.Gateway.OPCode do
  use Remedy.Type, docs: false

  defstruct DISPATCH: 0,
            HEARTBEAT: 1,
            IDENTIFY: 2,
            PRESENCE_UPDATE: 3,
            VOICE_STATE_UPDATE: 4,
            VOICE_SERVER_PING: 5,
            RESUME: 6,
            RECONNECT: 7,
            REQUEST_GUILD_MEMBERS: 8,
            INVALID_SESSION: 9,
            HELLO: 10,
            HEARTBEAT_ACK: 11,
            SYNC_GUILD: 12,
            SYNC_CALL: 13
end
