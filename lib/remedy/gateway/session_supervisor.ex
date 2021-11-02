defmodule Remedy.Gateway.SessionSupervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Gateway.Session

  def start_link(%{shard: shard} = opts) do
    Supervisor.start_link(__MODULE__, opts, name: :"shard_#{shard}")
  end

  def init(opts) do
    children = [{Session, opts}]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 3, max_seconds: 60)
  end
end
