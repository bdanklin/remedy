defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  use Remedy.Schema
  @primary_key false

  # either "idle", "dnd", "online", or "offline"

  embedded_schema do
    field :heartbeat_interval, :integer
  end

  def digest(socket, )
end

# def handle(:HELLO, %Websocket{payload_data: %{heartbeat_interval: heartbeat_interval}} = socket) do
# %Websocket{socket | heartbeat_interval: heartbeat_interval}
# |> log_event()
# |> start_pacemaker()
# |> send_identify()
# |> IO.inspect(label: "identify")
# end
