defmodule Remedy.Buffer.Out do
  @moduledoc false

  use GenStage
  require Logger

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:consumer, [], subscribe_to: [Remedy.Buffer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      event
      |> Remedy.Dispatch.Producer.ingest()
    end

    {:noreply, [], state}
  end
end
