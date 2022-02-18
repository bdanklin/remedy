defmodule Remedy.Dispatch.Producer.State do
  @moduledoc false
  #############################################################################
  ## queue: Events to be sent
  ## demand: any pending demand (probably always zero)
  ##
  defstruct queue: :queue.new(),
            demand: 0

  def handle_ingest(%__MODULE__{queue: queue} = state, message) do
    %__MODULE__{state | queue: :queue.in(message, queue)}
    |> dispatch_events()
  end

  def handle_demand(%__MODULE__{demand: demand} = state, incoming_demand) do
    %__MODULE__{state | demand: demand + incoming_demand}
    |> dispatch_events()
  end

  defp dispatch_events(state, events \\ [])

  defp dispatch_events(%__MODULE__{demand: 0} = state, events) do
    {:noreply, Enum.reverse(events), state}
  end

  defp dispatch_events(%__MODULE__{queue: {[], []}} = state, events) do
    {:noreply, Enum.reverse(events), state}
  end

  defp dispatch_events(%__MODULE__{queue: queue, demand: demand} = state, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        %__MODULE__{state | queue: queue, demand: demand - 1}
        |> dispatch_events([event | events])

      {:empty, _queue} ->
        state
        |> dispatch_events(events)
    end
  end

  def handle_drain(state) do
    with :ok <- Remedy.Buffer.sync_hold_push() do
      {:noreply, [], state}
    end
  end
end
