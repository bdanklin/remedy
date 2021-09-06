defmodule Remedy.Schema.WSState do
  @moduledoc false
  use Remedy.Schema, :model

  @primary_key false
  embedded_schema do
    field :shard_num, :integer
    field :seq, :integer
    field :session, :integer
    field :shard_pid, :any, virtual: true
    field :conn, :any, virtual: true
    field :conn_pid, :any, virtual: true
    field :stream, :any, virtual: true
    field :gateway, :string
    field :last_heartbeat_send, :utc_datetime
    field :last_heartbeat_ack, :utc_datetime
    field :heartbeat_ack, :boolean
    field :heartbeat_interval, :integer
    field :heartbeat_ref, :any, virtual: true
    field :zlib_ctx, :any, virtual: true
  end
end
