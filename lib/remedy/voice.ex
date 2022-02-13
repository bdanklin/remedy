defmodule Remedy.Voice do
  @moduledoc """
  Voice entry point.

  """
  use Supervisor
  alias Remedy.Voice.{Pool, Stagehand}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Pool, []},
      {Stagehand, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
