defmodule Remedy.Dispatch.Producer do
  @moduledoc false
  use GenStage

  @impl GenStage
  def init(_opts) do
    {:producer_consumer, :state, [dispatcher: GenStage.DemandDispatcher, subscribe_to: [Remedy.Buffer]]}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    {:noreply, [events], state, :hibernate}
  end

  @impl GenStage
  def handle_demand(_incoming_demand, state) do
    {:noreply, [], state, :hibernate}
  end
end
