defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  use Remedy.Schema
  @primary_key false

  # either "idle", "dnd", "online", or "offline"

  embedded_schema do
    field :heartbeat_interval, :integer
  end
end
