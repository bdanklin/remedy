defmodule Remedy.Gateway.Events.Hello do
  @moduledoc false
  use Remedy.Gateway.Payload

  defp digest(%Websocket{session_id: nil} = socket, %{heartbeat_interval: heartbeat_interval}) do
    IO.inspect(heartbeat_interval)

    %Websocket{socket | heartbeat_interval: heartbeat_interval}
    |> Payload.send(:IDENTIFY)
    |> Pacemaker.start()
  end
end
