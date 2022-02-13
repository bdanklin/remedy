defmodule Remedy.Dispatch do
  @moduledoc false
  alias Remedy.Dispatch.Processor

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Processor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
