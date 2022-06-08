defmodule Remedy.Rest.Lifeguard do
  @moduledoc false
  use GenServer
  alias Remedy.Rest.Lifeguard.State
  require Logger
  ############################################################################
  ##
  ## If workers = :auto                 we will start @default_worker_count
  ## If workers > @default_worker_count we will start @default_worker_count
  ## If workers < @default_worker_count we will start workers
  ##

  def assign_worker do
    GenServer.call(__MODULE__, :assign_worker)
  end

  def return_worker(worker) do
    GenServer.cast(__MODULE__, {:return_worker, worker})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    {:ok,
     args
     |> State.handle_init(), {:continue, :continue_init}}
  end

  @impl GenServer
  def handle_continue(:continue_init, state) do
    {:noreply,
     state
     |> State.handle_continue_init()}
  end

  @impl GenServer
  def handle_call(:assign_worker, from, state) do
    {:noreply,
     state
     |> State.handle_assign_worker(from)}
  end

  @impl GenServer
  def handle_cast({:return_worker, worker}, state) do
    {:noreply,
     state
     |> State.handle_return_worker(worker)}
  end
end
