defmodule Remedy.OpcodeHelpers do
  @moduledoc false

  @op %{
    0 => "DISPATCH",
    1 => "HEARTBEAT",
    2 => "IDENTIFY",
    3 => "STATUS_UPDATE",
    4 => "VOICE_STATUS_UPDATE",
    5 => "VOICE_SERVER_PING",
    6 => "RESUME",
    7 => "RECONNECT",
    8 => "REQUEST_GUILD_MEMBERS",
    9 => "INVALID_SESSION",
    10 => "HELLO",
    11 => "HEARTBEAT_ACK",
    12 => "SYNC_GUILD",
    13 => "SYNC_CALL"
  }

  def op(event) do
    @op
    |> Enum.filter(fn {_k, v} -> v == event end)
    |> List.first()
    |> Tuple.to_list()
    |> List.first()
  end

  def event(op), do: @op[op]

  def event_atom(op), do: @op[op] |> String.to_atom()
end
