defmodule Remedy.Rest.Lifeguard do
  @moduledoc false

  ## The lifeguard has two cycles

  ## Every cycle it checks the message queues of each worker to determine if new workers should be spawned
  ## Every 1000ms it will deduct from any unused workers TTL

  ## The lifeguard is responsible for:

  use GenServer
  require Logger
  alias Remedy.Rest.Pool
  alias Remedy.Rest.Lifeguard.State

  def assign_worker do
    GenServer.call(__MODULE__, :next_worker)
  end

  def return_to_pool(worker) do
    GenServer.cast(__MODULE__, {:return_to_pool, worker})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    with {:ok, children} <- initialize_children(args) do
      {:ok,
       State.new(args)
       |> State.put_children(children)
       |> State.pulse()}
    end
  end

  @impl true
  def handle_cast({:return_to_pool, worker}, state) do
    {:noreply,
     state
     |> State.return_to_pool(worker)}
  end

  @impl true
  def handle_call(:next_worker, _from, state) do
    next_worker = next_worker(state)

    {:reply, next_worker,
     state
     |> State.checkout_worker(next_worker)}
  end

  defp next_worker(%State{pool: pool}) do
    pool
    |> MapSet.to_list()
    |> List.first(1)
  end

  @impl true
  def handle_info(:pulse, state) do
    {:noreply,
     state
     |> State.pulse()}
  end

  def initialize_children(args) do
    with min <- Keyword.get(args, :min_workers) do
      started =
        Enum.reduce(1..min, [], fn
          child, acc ->
            [Task.async(fn -> Pool.start_child(child) end) | acc]
        end)
        |> Enum.map(&Task.await/1)
        |> Enum.count()

      {:ok, started}
    end
  end
end
