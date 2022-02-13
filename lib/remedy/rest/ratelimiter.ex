defmodule Remedy.Rest.Ratelimiter do
  @moduledoc false
  use GenServer

  @doc false
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @doc false
  def init(_args) do
    {:ok, :initial_state}
  end
end
