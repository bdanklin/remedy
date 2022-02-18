defmodule Remedy.Dispatch do
  @moduledoc """
  The Dispatch module is concerned with processing events from `Remedy.Gateway` and `Remedy.Voice`.
  """
  use Supervisor

  # TODO: Functions for rearranging Broadway Topology

  @doc false
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def child_spec(init_arg) do
    default = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :supervisor
    }

    Supervisor.child_spec(default, [])
  end

  @doc false
  def init(_args) do
    children = [
      {Remedy.Dispatch.Pipeline, []}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 1000, max_seconds: 60)
  end
end
