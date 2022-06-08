defmodule Remedy.Rest.Pool do
  @moduledoc false
  use DynamicSupervisor

  def start_child(args) do
    DynamicSupervisor.start_child(__MODULE__, {Remedy.Rest.Connection, args})
  end

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
