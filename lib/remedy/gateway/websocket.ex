defmodule Remedy.Gateway.Websocket do
  @moduledoc """
  Contains all the information required to maintain the gateway websocket connection to Discord.
  """
  use Remedy.Schema

  @type shard :: :integer
  @type session_id :: String.t()
  @type shard_pid :: pid()
  @type heartbeat_interval :: integer()
  @type worker :: pid()

  @primary_key false
  embedded_schema do
    # We know all this when connecting
    field :token, :string, redact: true, default: Application.get_env(:remedy, :token)
    field :shard, :integer
    field :gateway, :string

    # Need to store to maintain connection
    field :session_id, :string
    field :shard_pid, :any, virtual: true
    field :heartbeat_interval, :integer

    # Gun INfo
    field :gun_worker, :any, virtual: true
    field :gun_conn, :any, virtual: true
    field :gun_data_stream, :any, virtual: true
    field :zlib_context, :any, virtual: true

    # Heartbeat
    field :last_heartbeat_send, :utc_datetime
    field :last_heartbeat_ack, :utc_datetime
    field :heartbeat_ack, :boolean, default: false
    field :heartbeat_timer, :any, virtual: true

    # Payload items that can actually be used.
    field :payload_op_code, :integer, default: 0
    field :payload_op_event, :string, default: ""
    field :payload_sequence, :integer
    field :payload_data, :any, virtual: true
    field :payload_dispatch_event, :string
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
