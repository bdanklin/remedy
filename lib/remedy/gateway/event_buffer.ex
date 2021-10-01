defmodule Remedy.Gateway.EventBuffer do
  @moduledoc false

  use GenStage

  alias Remedy.Gateway.{Dispatch, EventBroadcaster}

  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, [], subscribe_to: [EventBroadcaster]}
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
