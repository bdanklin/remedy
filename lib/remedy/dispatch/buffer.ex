defmodule Remedy.Gateway.Buffer do
  @moduledoc false

  use GenStage
  alias Remedy.Gateway.{Producer, EventHandler}

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, [], subscribe_to: [Producer]}
  end

  def handle_events(events, _from, state) do
    {:noreply,
     events
     |> dispatch(), state, :hibernate}
  end

  defp dispatch(events) do
    events
    |> Task.async_stream(fn event -> event |> EventHandler.handle() end, timeout: :infinity)
    |> Enum.reduce([], fn {:ok, event}, acc -> [event] ++ acc end)
    |> List.flatten()
    |> Enum.filter(fn event -> event != :noop end)
  end
end
