defmodule Remedy.Voice.Pool do
  @moduledoc false
  use DynamicSupervisor

  def start_child(args) do
    DynamicSupervisor.start_child(__MODULE__, {Remedy.Voice.Session, args})
  end

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 10, max_seconds: 60)
  end
end
