defmodule Remedy.Dispatch.Producer do
  @moduledoc false
  require Logger
  alias Remedy.Dispatch.Producer.State

  use GenStage
  @spec start_link(any) :: {:ok, pid}
  @doc false
  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  @impl GenStage
  @spec init(any) :: {:producer, %State{}}
  def init(_opts) do
    {:producer, %State{}}
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    state
    |> State.handle_demand(incoming_demand)
  end

  alias Broadway.Producer
  @behaviour Producer

  @impl Producer
  def prepare_for_draining(state) do
    state
    |> State.handle_drain()
  end
end
