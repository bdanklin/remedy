defmodule Remedy.Gateway.ATC do
  @moduledoc false

  use GenServer
  require Logger
  alias Remedy.Gateway.ATC.State

  def request_connection(%{shard: shard}) do
    Logger.info("Trying to connect shard #{shard}")
    GenServer.call(__MODULE__, :request_connection, :infinity)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok,
     args
     |> State.new()}
  end

  def handle_call(:request_connection, _from, state) do
    with :ok <- State.handle_request_connection(state) do
      {:reply, :ok, state}
    end
  end
end
