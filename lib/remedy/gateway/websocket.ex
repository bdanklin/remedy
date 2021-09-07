defmodule Remedy.Gateway.Websocket do
  @moduledoc false
  use Remedy.Schema, :model

  @primary_key false
  embedded_schema do
    field :shard_num, :integer
    field :seq, :integer
    field :session, :integer
    field :shard_pid, :any, virtual: true
    field :conn, :any, virtual: true
    field :conn_pid, :any, virtual: true
    field :stream, :any, virtual: true
    field :gateway, :string
    field :last_heartbeat_send, :utc_datetime
    field :last_heartbeat_ack, :utc_datetime
    field :heartbeat_ack, :boolean
    field :heartbeat_interval, :integer
    field :heartbeat_ref, :any, virtual: true
    field :zlib_ctx, :any, virtual: true
  end

  @doc """
  Gets the latency of the shard connection from a `Remedy.Struct.Websocket.t()` struct.

  Returns the latency in milliseconds as an integer, returning nil if unknown.
  """
  def get_shard_latency(%__MODULE__{last_heartbeat_ack: nil}), do: nil

  def get_shard_latency(%__MODULE__{last_heartbeat_send: nil}), do: nil

  def get_shard_latency(
        %__MODULE__{
          last_heartbeat_ack: last_heartbeat_ack,
          last_heartbeat_send: last_heartbeat_send
        } = state
      ) do
    latency = DateTime.diff(last_heartbeat_ack, last_heartbeat_send, :millisecond)

    max(0, latency + if(latency < 0, do: state.heartbeat_interval, else: 0))
  end
end
