defmodule Remedy.Gateway.EventBroadcaster do
  @moduledoc false

  use GenStage

  require Logger

  @doc """

  """
  def digest(event) do
    GenStage.cast(__MODULE__, {:notify, event})
  end

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  def handle_cast({:notify, event}, {queue, demand}) do
    dispatch_events(:queue.in(event, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, demand + incoming_demand, [])
  end

  def dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand, {{:value, payload}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [payload | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}, :hibernate}
    end
  end
end
