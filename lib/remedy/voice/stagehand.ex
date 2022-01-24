defmodule Remedy.Voice.Stagehand do
  # Ensure each guild has a session waiting for voice connections
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, :initial_state}
  end
end
