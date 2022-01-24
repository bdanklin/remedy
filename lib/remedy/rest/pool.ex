defmodule Remedy.Rest.Pool do
  @moduledoc false
  use DynamicSupervisor

  def start_child(number) do
    DynamicSupervisor.start_child(__MODULE__, {Remedy.Rest.Connection, [number]})
  end

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
