defmodule Remedy.Gateway.EventAdmission do
  @moduledoc false

  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  def digest(socket) do
    GenStage.cast(__MODULE__, {:notify, socket})
  end

  @spec handle_cast({:notify, any}, {:queue.queue(any), any}) :: {:noreply, list, {any, any}, :hibernate}
  def handle_cast({:notify, socket}, {queue, demand}) do
    dispatch_events(:queue.in(socket, queue), demand, [])
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

defmodule Remedy.Gateway.EventBuffer do
  @moduledoc false

  use GenStage

  alias Remedy.Shard.Dispatch
  alias Remedy.Gateway.EventAdmission

  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, [], subscribe_to: [EventAdmission]}
  end

  def handle_events(events, _from, state) do
    {:noreply,
     events
     |> dispatch(), state, :hibernate}
  end

  defp dispatch(events) do
    events
    |> Enum.map(&Dispatch.handle/1)
    |> List.flatten()
    |> Enum.filter(fn event -> event != :noop end)
  end
end
