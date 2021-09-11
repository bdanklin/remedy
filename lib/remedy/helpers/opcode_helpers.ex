defmodule Remedy.OpcodeHelpers do
  @moduledoc false
  defguard is_op_code(code)
           when code in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

  defguard is_op_event(event)
           when event in [
                  :DISPATCH,
                  :HEARTBEAT,
                  :IDENTIFY,
                  :STATUS_UPDATE,
                  :VOICE_STATUS_UPDATE,
                  :VOICE_SERVER_PING,
                  :RESUME,
                  :RECONNECT,
                  :REQUEST_GUILD_MEMBERS,
                  :INVALID_SESSION,
                  :HELLO,
                  :HEARTBEAT_ACK,
                  :SYNC_GUILD,
                  :SYNC_CALL
                ]

  def opcodes do
    [
      {:DISPATCH, 0},
      {:HEARTBEAT, 1},
      {:IDENTIFY, 2},
      {:STATUS_UPDATE, 3},
      {:VOICE_STATUS_UPDATE, 4},
      {:VOICE_SERVER_PING, 5},
      {:RESUME, 6},
      {:RECONNECT, 7},
      {:REQUEST_GUILD_MEMBERS, 8},
      {:INVALID_SESSION, 9},
      {:HELLO, 10},
      {:HEARTBEAT_ACK, 11},
      {:SYNC_GUILD, 12},
      {:SYNC_CALL, 13}
    ]
  end

  def op_code(event)
      when is_binary(event)
      when event in [
             "DISPATCH",
             "HEARTBEAT",
             "IDENTIFY",
             "STATUS_UPDATE",
             "VOICE_STATUS_UPDATE",
             "VOICE_SERVER_PING",
             "RESUME",
             "RECONNECT",
             "REQUEST_GUILD_MEMBERS",
             "INVALID_SESSION",
             "HELLO",
             "HEARTBEAT_ACK",
             "SYNC_GUILD",
             "SYNC_CALL"
           ] do
    String.to_atom(event) |> op_code()
  end

  def op_code(event), do: opcodes()[event]
  def op_event(opcode), do: Enum.find(opcodes(), fn {_, v} -> v == opcode end) |> Tuple.to_list() |> List.first()
end
