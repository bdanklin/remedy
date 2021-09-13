defmodule Remedy.Bot do
  import Remedy.ModelHelpers

  @moduledoc """
  Simple cache that stores information for the current user.
  """

  def start_link(_args) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  @spec get() :: User.t() | nil
  def get do
    Agent.get(__MODULE__, fn user -> user end)
  end

  def put(%Remedy.Schema.User{} = user) do
    Agent.update(__MODULE__, fn _ -> user end)
  end

  def update(%{} = values) do
    Agent.update(__MODULE__, fn state ->
      struct(state, values)
    end)
  end

  def delete do
    Agent.update(__MODULE__, fn _ -> nil end)
  end
end
