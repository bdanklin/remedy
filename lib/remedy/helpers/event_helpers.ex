defmodule Remedy.EventHelpers do
  alias Remedy.Gateway.Events.{
          Dispatch,
          Heartbeat,
          HeartbeatAck,
          Hello,
          Idenitfy,
          RequestGuildMembers,
          Resume,
          UpdatePresence,
          UpdateVoiceState
        },
        warn: false

  def command_from_module do
    __MODULE__
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> Recase.to_snake()
    |> String.upcase()
  end
end
