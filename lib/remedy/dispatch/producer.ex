defmodule Remedy.Dispatch.Producer do
  @moduledoc false
  require Logger

  use GenStage
  alias Remedy.Dispatch.Producer.State

  @doc false
  def ingest(event) do
    Logger.warn("RECEIVED #{inspect(event)}")
    GenStage.cast(__MODULE__, {:ingest, event})
  end

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenStage
  def init(_opts) do
    Logger.error("#{inspect(__MODULE__)} INIT CALLED")
    {:producer, %State{}}
  end

  @impl GenStage
  def handle_cast({:ingest, event}, state) do
    Logger.error("Remedy.Dispatch.Producer BUFFERING EVENT #{inspect(event)}")

    state
    |> State.handle_ingest(event)
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    Logger.error("Remedy.Dispatch.Producer INCOMING_DEMAND_TO_BUFFER #{incoming_demand}")

    state
    |> State.handle_demand(incoming_demand)
  end

  # @impl GenStage
  # def handle_info({:retry, hash}, state) do
  #   State.handle_retry(state, hash)
  # end
end
