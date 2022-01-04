defmodule Remedy.Gateway do
  @moduledoc false
  use Supervisor
  alias Remedy.Gateway.{EventBroadcaster, EventBuffer, SessionSupervisor}
  require Logger
  import Remedy, only: [shards: 0]

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
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def init(_shards) do
    children =
      [
        EventBroadcaster,
        EventBuffer
      ] ++ shard_workers()

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp shard_workers() do
    for shard <- 0..(shards() - 1), into: [] do
      Supervisor.child_spec({SessionSupervisor, %{shard: shard}}, id: shard)
    end
  end
end
