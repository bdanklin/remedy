defmodule Remedy.Bot do
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args])
  end

  def init(_args) do
    {:ok, :initial_state}
  end
end
