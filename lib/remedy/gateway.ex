defmodule Remedy.Gateway do
  @moduledoc """
  The Gateway provides real time events to your application as they occur on Discord.

  """
  use Supervisor

  require Logger

  alias Remedy.Gateway.ATC
  alias Remedy.Gateway.Pool

  @doc false
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def child_spec(init_arg) do
    default = %{id: __MODULE__, start: {__MODULE__, :start_link, [init_arg]}, type: :supervisor}
    Supervisor.child_spec(default, [])
  end

  @doc false
  def init(args) do
    children = [
      {Registry, keys: :unique, name: Remedy.GatewayRegistry},
      {ATC, []},
      {Pool, []},
      {Task, fn -> start_shards(args) end}
    ]

    Supervisor.init(children, strategy: :rest_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp start_shards(args) do
    shards = shards_from_args(args)
    IO.inspect("SHARDS TO START: #{shards}")
    shard_ids = 0..(shards - 1)
    args = Keyword.put(args, :shards, shards)

    for shard <- shard_ids do
      args = Keyword.put_new(args, :shard, shard)

      Pool.start_child(args)
    end
  end

  defp shards_from_args(args) do
    case args[:shards] do
      int when is_integer(int) -> int
      :auto -> (Remedy.API.get_gateway_bot() |> elem(1)).shards
    end
  end
end
