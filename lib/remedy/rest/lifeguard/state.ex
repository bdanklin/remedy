defmodule Remedy.Rest.Lifeguard.State do
  @moduledoc false
  @auto_default_worker_count 100
  @minimum_worker_count 5
  ## active: Currently Running Workers
  ## pool: Currently Available Workers
  ## util: Worker Usage

  defstruct workers: :auto,
            active: %MapSet{},
            pool: %MapSet{},
            util: %{},
            pulse: nil,
            token: ""

  #############################################################################
  ## Init
  @spec handle_init(keyword) :: %__MODULE__{}
  def handle_init(args) do
    %__MODULE__{
      workers: Keyword.get(args, :workers, :auto),
      token: Keyword.get(args, :token)
    }
    |> spawn_initial_workers()
  end

  defp spawn_initial_workers(%__MODULE__{workers: workers} = state)
       when workers >= @minimum_worker_count
       when workers == :auto do
    spawn_workers(state, @minimum_worker_count)
  end

  defp spawn_initial_workers(%__MODULE__{workers: workers} = state)
       when workers < @minimum_worker_count do
    spawn_workers(state, workers)
  end

  @spec handle_continue_init(%__MODULE__{}) :: %__MODULE__{}
  def handle_continue_init(%__MODULE__{workers: workers} = state)
      when workers == :auto,
      do: spawn_workers(state, @auto_default_worker_count)

  def handle_continue_init(%__MODULE__{workers: workers} = state)
      when is_integer(workers),
      do: spawn_workers(state, workers)

  defp spawn_workers(%__MODULE__{token: token, active: active} = state, to_start)
       when is_list(to_start) do
    workers_to_start =
      to_start
      |> MapSet.new()
      |> MapSet.difference(active)
      |> MapSet.to_list()

    active =
      Enum.reduce(workers_to_start, [], fn
        worker, acc ->
          [Task.async(fn -> spawn_worker(worker, token) end) | acc]
      end)
      |> Task.await_many(:infinity)
      |> MapSet.new()
      |> MapSet.union(active)

    %__MODULE__{state | active: active}
  end

  defp spawn_workers(%__MODULE__{} = state, workers)
       when is_integer(workers),
       do: spawn_workers(state, 0..workers |> Enum.to_list())

  defp spawn_worker(worker, token) do
    with {:ok, _pid} <-
           Remedy.Rest.Pool.start_child(%{worker: worker, token: token}) do
      worker
    end
  end

  ############################################################################
  ## Assign Worker
  require Logger
  @spec handle_assign_worker(%__MODULE__{}, {pid, any}) :: %__MODULE__{}
  def handle_assign_worker(%__MODULE__{active: active} = state, from) do
    with worker <- Enum.at(active, 0),
         :ok <- Logger.warn("Assigned Worker #{inspect(worker)}"),
         state <- %__MODULE__{state | active: MapSet.delete(active, worker)},
         :ok <- GenServer.reply(from, worker) do
      state
    end
  end

  ############################################################################
  ## Return Worker
  @spec handle_return_worker(%__MODULE__{}, integer) :: %__MODULE__{}
  def handle_return_worker(%__MODULE__{active: active} = state, worker) do
    %__MODULE__{state | active: MapSet.put(active, worker)}
  end
end
