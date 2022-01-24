defmodule Remedy.Rest.Lifeguard.State do
  @moduledoc false

  defstruct max: nil,
            min: nil,
            pool: nil,
            util: %{},
            pulse: nil

  def new(args) do
    min = args[:min_workers]
    max = args[:max_workers]

    %__MODULE__{min: min, max: max, pool: %MapSet{}}
  end

  def put_children(%__MODULE__{} = state, _pool) do
    state
  end

  def return_to_pool(%__MODULE__{pool: pool} = state, worker) do
    pool = MapSet.put(pool, worker)
    %__MODULE__{state | pool: pool}
  end

  def checkout_worker(%__MODULE__{pool: pool} = state, worker) do
    pool = MapSet.delete(pool, worker)
    %__MODULE__{state | pool: pool}
  end

  def pulse(%__MODULE__{} = state) do
    %__MODULE__{state | pulse: Process.send_after(self(), :pulse, 10000, [])}
  end
end
