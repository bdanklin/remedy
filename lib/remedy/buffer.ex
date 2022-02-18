defmodule Remedy.Buffer do
  @moduledoc false
  #############################################################################
  ## The buffer lives between the Gateways and the `Broadway` Pipeline.
  ##
  ## Separating this buffer from both of these systems affords us a number of
  ## conveniences.
  ##
  ## 1. We can re arrange the Shard topology while the system is running,
  ##    spawning additional shards as needed without concerns of overlapping
  ##    events or duplicate data.
  ##
  ## 2. We can re arrange the Broadway topology as required. This will pause
  ##    the systems ability to process data for a short time. (<50ms)
  ##
  ## There is no public interface for the Buffer. If you wish to modify the
  ## data processing pipeline, please use the functions within
  ## `Remedy.Gateway` and `Remedy.Dispatch`.

  use Supervisor
  alias Remedy.Buffer.{Left, Right}

  @doc false
  #############################################################################
  ## Hold Pushing Events
  ##
  ## This will only hold while Broadway.Dispatch.Pipeline is down.
  def sync_hold_push do
    Right.sync_hold_push()
  end

  @doc false
  #############################################################################
  ## Ingest an event from the Gateway
  def ingest(event) do
    Left.ingest(event)
  end

  @doc false
  def child_spec(init_arg) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [init_arg]}, type: :supervisor}
    |> Supervisor.child_spec([])
  end

  @doc false
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_arg) do
    Supervisor.init([{Left, []}, {Right, []}], strategy: :one_for_one)
  end
end
