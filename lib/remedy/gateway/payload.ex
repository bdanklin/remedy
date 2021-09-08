defmodule Remedy.Gateway.Payload do
  @moduledoc false
  use Remedy.Schema, :payload
  @primary_key false
  embedded_schema do
    field :op, :integer
    field :d, :map
    field :s, :string
    field :t, :string
  end

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
    |> Enum.into([])
    |> List.first()
  end

  def event(op), do: @op[op]

  def build(data, event, s \\ nil) do
    %{
      d: data,
      t: event,
      s: s,
      op: op(event)
    }
    |> new()
    |> :erlang.term_to_binary()
  end

  # breakdown
  def raze(payload) do
    payload |> new()
  end
end
