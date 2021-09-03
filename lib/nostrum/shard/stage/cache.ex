defmodule Remedy.Shard.Stage.Cache do
  @moduledoc false

  use GenStage

  alias Remedy.Shard.Dispatch
  alias Remedy.Shard.Stage.Producer
  alias Remedy.Util

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__, spawn_opt: [Util.fullsweep_after()])
  end

  def init(_opts) do
    {:producer_consumer, [], subscribe_to: [Producer]}
  end

  def handle_events(events, _from, state) do
    flat_processed_events =
      events
      |> Enum.map(&Dispatch.handle/1)
      |> List.flatten()
      |> Enum.filter(fn event -> event != :noop end)

    {:noreply, flat_processed_events, state, :hibernate}
  end
end
