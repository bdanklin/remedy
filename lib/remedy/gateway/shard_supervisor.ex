defmodule Remedy.Gateway.ShardSupervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Gateway.ShardSession

  def start_link(%{shard: shard} = opts) do
    Supervisor.start_link(__MODULE__, opts, name: :"Shard-#{shard}")
  end

  def init(opts) do
    children = [
      {ShardSession, opts}
    ]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 3, max_seconds: 60)
  end
end
