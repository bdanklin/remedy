defmodule Remedy.Buffer.Producer do
  @moduledoc false
  require Logger
  ## The buffer will store events from all gateway shards with the ability to
  ## resend events that are not ack'd for any reason.
  ##
  ## The buffer is separate to the Gateway and the Dispatch trees so that it
  ## will not lose events in the case of shard or dispatch supervision tree
  ## rebuilds. Allowing the pipelines to be rebuilt while the application is
  ## running without loss of data.

  @behaviour Broadway.Acknowledger
  @impl Broadway.Acknowledger
  def ack(ack_ref, successful, failed) do
    GenStage.cast(__MODULE__, {ack_ref, successful, failed})
  end

  use GenStage
  alias Remedy.Buffer.Producer.State

  @doc false
  def ingest(event) do
    GenStage.cast(__MODULE__, {:ingest, event})
  end

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenStage
  def init(_opts) do
    {:producer, %State{}, dispatcher: GenStage.DemandDispatcher}
  end

  @impl GenStage
  @spec handle_cast({:ingest, {any, any, any}}, %State{}) :: {:noreply, list, %State{}, :hibernate}
  def handle_cast({:ingest, event}, state) do
    state
    |> State.handle_ingest(event)
  end

  @spec handle_cast({any, any, any}, %State{}) :: {:noreply, list, %State{}, :hibernate}
  def handle_cast({_ack_ref, _successful, _failed} = ack, state) do
    state
    |> State.handle_ack(ack)
  end

  @impl GenStage
  @spec handle_demand(any, %State{}) :: {:noreply, list, %State{}, :hibernate}
  def handle_demand(incoming_demand, state) do
    state
    |> State.handle_demand(incoming_demand)
  end

  # @impl GenStage
  # def handle_info({:retry, hash}, state) do
  #   State.handle_retry(state, hash)
  # end
end
