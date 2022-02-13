defmodule Remedy.Gateway do
  @moduledoc """
  Gateway Documentation
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
  def init(args) do
    children = [
      {Pool, []},
      {ATC, []},
      {Task, fn -> start_shards(args) end}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
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
