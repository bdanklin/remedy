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
          gateway: String.t(),
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
  def info do
    {:ok, %{shards: shards, url: "wss://" <> url}} = API.get_gateway_bot()

    %{url: url, shards: shards}
  end

  @doc false
  def num_shards, do: info().shards

  @doc false
  def start_link(_args) do
    %{url: _url, shards: _shards} = state = info()

    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc false
  def init(%{url: url, shards: shards}) do
    children =
      [
        EventBroadcaster,
        EventBuffer
      ] ++ shard_workers(url, shards)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp shard_workers(gateway, shards),
    do: for(shard <- 0..(shards - 1), into: [], do: shard_worker(gateway, shard))

  defp shard_worker(gateway, shard) do
    Supervisor.child_spec({SessionSupervisor, %{gateway: gateway, shard: shard}}, id: shard)
  end
end
