defmodule Remedy.Gateway.Payload do
  @moduledoc false
  use Remedy.Schema, :model

  @defaults %{
    "op" => "",
    "d" => %{},
    "s" => "",
    "t" => ""
  }

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

  def identify() do
    %{
      "token" => "Application.get_env(:remedy, :token)",
      "properties" => %{
        "$os" => "",
        "$browser" => "Remedy",
        "$device" => "Remedy",
        "$referrer" => "",
        "$referring_domain" => ""
      },
      "compress" => false,
      "large_threshold" => "@large_threshold",
      "shard" => "[state.shard_num, Util.num_shards()]",
      "intents" => "Intents.get_enabled_intents()"
    }
  end

  def resume() do
    %{
      "token" => "Application.get_env(:remedy, :token)",
      "session_id" => "state.session",
      "seq" => "state.seq"
    }
  end

  def update_presence() do
    %{
      "since" => 91_879_201,
      "status" => "online",
      "afk" => false
    }
  end

  def update_voice_state() do
    %{
      "guild_id" => "guild_id",
      "channel_id" => "channel_id",
      "self_mute" => "self_mute",
      "self_deaf" => "self_deaf"
    }
  end

  def guild_request_members() do
    %{
      "guild_id" => "41771983444115456",
      "query" => "",
      "limit" => 0
    }
  end
end