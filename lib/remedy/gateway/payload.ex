defmodule Remedy.Gateway.Payload do
  @moduledoc false
  use Remedy.Schema, :payload

  @primary_key false
  embedded_schema do
    field :op, :integer
    field :d, :map
    field :s, :string
    field :t, :string
  end

  @op %{
    "DISPATCH" => 0,
    "HEARTBEAT" => 1,
    "IDENTIFY" => 2,
    "STATUS_UPDATE" => 3,
    "VOICE_STATUS_UPDATE" => 4,
    "VOICE_SERVER_PING" => 5,
    "RESUME" => 6,
    "RECONNECT" => 7,
    "REQUEST_GUILD_MEMBERS" => 8,
    "INVALID_SESSION" => 9,
    "HELLO" => 10,
    "HEARTBEAT_ACK" => 11,
    "SYNC_GUILD" => 12,
    "SYNC_CALL" => 13
  }

  defp op(event), do: @op |> Map.get(event)

  def build(data, event, s \\ nil) do
    %{
      d: data,
      t: event,
      s: s,
      op: op(event)
    }
    |> new()
  end

  def update_presence do
    %{
      "since" => 91_879_201,
      "status" => "online",
      "afk" => false
    }
  end

  def update_voice_state do
    %{
      "guild_id" => "guild_id",
      "channel_id" => "channel_id",
      "self_mute" => "self_mute",
      "self_deaf" => "self_deaf"
    }
  end

  def guild_request_members do
    %{
      "guild_id" => "",
      "query" => "",
      "limit" => 0
    }
  end
end
