defmodule Remedy.Gateway.Producer do
  @moduledoc false

  use GenStage

  require Logger

  @spec digest(any) :: :ok
  @doc false
  def digest(event) do
    GenStage.cast(__MODULE__, {:notify, event})
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec init(any) :: {:producer, {:queue.queue(any), 0}, [{:dispatcher, GenStage.DemandDispatcher}, ...]}
  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  @spec handle_cast({:notify, any}, {:queue.queue(any), any}) :: {:noreply, list, {any, any}, :hibernate}
  def handle_cast({:notify, event}, {queue, demand}) do
    dispatch_events(:queue.in(event, queue), demand, [])
  end

  @spec handle_demand(number, {any, number}) :: {:noreply, list, {any, any}, :hibernate}
  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, demand + incoming_demand, [])
  end

  @spec dispatch_events(any, any, any) :: {:noreply, list, {any, any}, :hibernate}
  def dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand, {{:value, payload}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [payload | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}, :hibernate}
    end
  end
end
