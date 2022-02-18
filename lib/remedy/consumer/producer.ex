defmodule Remedy.Consumer.Producer do
  @moduledoc false
  require Logger
  use GenStage

  @spec ingest(any) :: :ok
  @doc false
  def ingest(event) do
    GenStage.cast(__MODULE__, {:ingest, event})
  end

  @doc false
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  @impl GenStage
  @spec init(any) :: {:producer, :state, [{:dispatcher, GenStage.BroadcastDispatcher}]}
  def init(_opts) do
    {:producer, :state, [dispatcher: GenStage.BroadcastDispatcher]}
  end

  @impl GenStage
  @spec handle_cast({:ingest, any}, any) :: {:noreply, [...], any, :hibernate}
  def handle_cast({:ingest, event}, state) do
    Logger.error("CONSUMER_PRODUCER_INGESTED_EVENT")
    {:noreply, [event], state, :hibernate}
  end

  @impl GenStage
  @spec handle_demand(any, any) :: {:noreply, [], any, :hibernate}
  def handle_demand(_incoming_demand, state) do
    {:noreply, [], state, :hibernate}
  end
end
