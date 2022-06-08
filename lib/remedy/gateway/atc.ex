defmodule Remedy.Gateway.ATC do
  @moduledoc false

  use GenServer
  require Logger
  alias Remedy.Gateway.ATC.State

  def request_connection(%{shard: shard, shards: shards, intents: intents} = socket) do
    with :ok <- Logger.info("Shard:#{shard} Requesting Clearance To Connect"),
         :ok <- GenServer.call(__MODULE__, :request_connection, :infinity),
         :ok <- Logger.info("Shard:#{shard} Clearance Granted") do
      socket
    end
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
    {:reply, :ok,
     state
     |> State.handle_request_connection()}
  end
end
