defmodule Remedy.Voice.OPCode do
  use Remedy.Type

  @doc false
  defstruct IDENTIFY: 0,
            SELECT_PROTOCOL: 1,
            READY: 2,
            HEARTBEAT: 3,
            SESSION_DESCRIPTION: 4,
            SPEAKING: 5,
            HEARTBEAT_ACK: 6,
            RESUME: 7,
            HELLO: 8,
            RESUMED: 9,
            UNDOCUMENTED_10: 10,
            UNDOCUMENTED_11: 11,
            CLIENT_CONNECT: 12,
            CLIENT_DISCONNECT: 13,
            CODEC_INFO: 14
end
