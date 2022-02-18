defmodule Remedy.Buffer.Right do
  @moduledoc false

  use GenStage
  require Logger

  alias Remedy.Buffer.Right.State

  def sync_hold_push() do
    GenStage.call(__MODULE__, :sync_hold_push)
  end

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:consumer, State.new(), subscribe_to: [Remedy.Buffer.Left]}
  end

  def handle_call(:sync_hold_push, _from, state) do
    {:reply, :ok, [],
     state
     |> State.handle_sync_hold_push()}
  end

  def handle_info(:holding, state) do
    {:noreply, [],
     state
     |> State.handle_holding()}
  end

  def handle_events(events, _from, state) do
    {:noreply, [],
     state
     |> State.handle_events(events)}
  end
end
