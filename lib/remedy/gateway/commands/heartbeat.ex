defmodule Remedy.Gateway.Commands.Heartbeat do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :heartbeat_interval, :integer
  end
end
