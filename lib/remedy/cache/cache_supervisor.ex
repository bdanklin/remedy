defmodule Remedy.Cache.CacheSupervisor do
  @moduledoc false

  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], name: CacheSupervisor)
  end

  def init([]) do
    children = [
      Remedy.Cache.Me
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
