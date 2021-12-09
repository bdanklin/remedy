defmodule Remedy.Gateway.WSState do
  @moduledoc false
  # Contains all the information required to maintain the gateway websocket connection to Discord.
  #
  # This is provided to allow the user to enact custom logic on the gateway events as they are received from the #consumer. It should be noted that the websocket state consumed with an event is a 'snapshot' of the state at the time #that event was received, and does not relate to the current state of the websocket.
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :conn, :any, virtual: true
    field :data_stream, :any, virtual: true
    field :zlib_context, :any, virtual: true

    field :heartbeat_timer, :any, virtual: true
    field :shard_pid, :any, virtual: true, default: self()
    field :token, :string, default: Application.get_env(:remedy, :token)

    field :gateway, :string
    field :heartbeat_ack, :boolean

    field :heartbeat_interval, :integer
    field :last_heartbeat_ack, :utc_datetime
    field :last_heartbeat_send, :utc_datetime

    field :payload_dispatch_event, :any, virtual: true
    field :payload_op_code, :integer, default: 0
    field :payload_op_event, :string, default: ""
    field :payload_sequence, :integer

    field :session_id, :string
    field :shard, :integer
    field :total_shards, :integer
    field :v, :integer
  end

  @doc """
  Gets the latency of the shard connection from a `Remedy.Struct.WSState.t()` struct.

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
