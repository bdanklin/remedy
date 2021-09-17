defmodule Remedy.Bot do
  @moduledoc false
  use GenServer

  def get do
    GenServer.call(__MODULE__, :current_state)
  end

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    {:ok, :initial_state}
  end

  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end
end
