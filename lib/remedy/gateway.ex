defmodule Remedy.Gateway do
  @moduledoc """
  Exposes functions for gateway interraction.
  """

  use Supervisor
  alias Remedy.API
  alias Remedy.Gateway.{EventBroadcaster, EventBuffer, SessionSupervisor}
  require Logger

  @typedoc """
  The websocket state transmitted along with events to the consumer.
  """
  @type socket :: %{
          heartbeat_ack: boolean(),
          last_heartbeat_ack: DateTime.t() | nil,
          last_heartbeat_send: DateTime.t() | nil,
          payload_dispatch_event: atom(),
          payload_op_code: integer(),
          payload_op_event: atom(),
          payload_sequence: integer(),
          session_id: String.t() | nil,
          shard: integer()
        }

  @doc false
  def recommended_shard_count(), do: API.get_gateway_bot!().shards

  def shard_count(), do: Application.get_env(:remedy, :ffmpeg) || recommended_shard_count()
  @doc false
  def start_link(_args) do
    shards = shard_count()
    Supervisor.start_link(__MODULE__, shards, name: __MODULE__)
  end

  @doc false
  def init(shards) do
    children =
      [
        EventBroadcaster,
        EventBuffer
      ] ++ shard_workers(shards)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp shard_workers(shards),
    do: for(shard <- 0..(shards - 1), into: [], do: shard_worker(shard))

  defp shard_worker(shard) do
    Supervisor.child_spec({SessionSupervisor, %{shard: shard}}, id: shard)
  end
end
