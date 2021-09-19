defmodule Remedy.Cache.DiscordApp do
  @moduledoc false
  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def update(new_state) do
    Agent.update(__MODULE__, fn _state -> new_state end)
  end

  def get do
    Agent.get(__MODULE__, fn state ->
      state
    end)
  end
end
