defmodule Remedy.Gateway.EventBuffer do
  @moduledoc false

  use GenStage
  alias Remedy.Gateway.{EventHandler, EventBroadcaster, EventParser}
  alias Remedy.Commands

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
    |> Task.async_stream(fn event ->
      event
      #    |> EventParser.handle()
      |> tap(&EventHandler.handle(&1))
      |> tap(&Task.start(Commands, :invoke, [&1]))
    end)
    |> Enum.reduce([], fn {:ok, event}, acc -> [event] ++ acc end)
    |> List.flatten()
    |> Enum.filter(fn event -> event != :noop end)
  end
end
