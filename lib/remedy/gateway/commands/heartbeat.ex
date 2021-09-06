defmodule Remedy.Gateway.Commands.Heartbeat do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :heartbeat_interval, :integer
  end

  def payload(state, opts \\ [])

  def payload(%WSState{heartbeat_interval: heartbeat_interval}, _opts) do
    %{
      heartbeat_interval: heartbeat_interval
    }
    |> build_payload()
  end
end
