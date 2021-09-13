defmodule Remedy.Gateway.Websocket do
  @moduledoc """
  Contains all the information required to maintain the gateway websocket connection to Discord.
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          token: token,
          shard: shard,
          gateway: gateway,
          session_id: session_id,
          shard_pid: shard_pid,
          heartbeat_interval: heartbeat_interval,
          gun_worker: gun_worker,
          gun_conn: gun_conn,
          gun_data_stream: gun_data_stream,
          zlib_context: zlib_context,
          last_heartbeat_send: last_heartbeat_send,
          last_heartbeat_ack: last_heartbeat_ack,
          heartbeat_ack: heartbeat_ack,
          heartbeat_timer: heartbeat_timer,
          payload_op_code: payload_op_code,
          payload_op_event: payload_op_event,
          payload_sequence: payload_sequence,
          payload_data: payload_data,
          payload_dispatch_event: payload_dispatch_event
        }

  @type token :: String.t()
  @type shard :: integer()
  @type gateway :: String.t()
  @type session_id :: String.t()
  @type shard_pid :: pid()
  @type heartbeat_interval :: integer()
  @type gun_worker :: pid()
  @type gun_conn :: pid()
  @type gun_data_stream :: Stream.t()
  @type zlib_context :: term()
  @type last_heartbeat_send :: DateTime.t()
  @type last_heartbeat_ack :: DateTime.t()
  @type heartbeat_ack :: boolean()
  @type heartbeat_timer :: integer()
  @type payload_op_code :: integer()
  @type payload_op_event :: atom()
  @type payload_sequence :: integer()
  @type payload_data :: any()
  @type payload_dispatch_event :: atom()

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
    # Heartbeat
    field :last_heartbeat_send, :utc_datetime
    field :last_heartbeat_ack, :utc_datetime
    field :heartbeat_ack, :boolean, default: false
    field :heartbeat_timer, :any, virtual: true
    # Gun INfo
    field :gun_worker, :any, virtual: true
    field :gun_conn, :any, virtual: true
    field :gun_data_stream, :any, virtual: true
    field :zlib_context, :any, virtual: true
    # Payload items that can actually be used.
    field :payload_op_code, :integer, default: 0
    field :payload_op_event, :string, default: ""
    field :payload_sequence, :integer
    field :payload_data, :any, virtual: true
    field :payload_dispatch_event, :any, virtual: true
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
