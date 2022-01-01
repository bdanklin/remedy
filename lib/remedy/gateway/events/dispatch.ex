defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  require Logger
  use Remedy.Gateway.Payload
  alias Remedy.Cache
  alias Remedy.Gateway.EventBroadcaster

  def digest(
        %WSState{payload_dispatch_event: :READY} = socket,
        %{
          geo_ordered_rtc_regions: _geo_ordered_rtc_regions,
          presences: [],
          private_channels: [],
          relationships: [],
          session_id: session_id,
          application: app,
          user: user,
          guilds: _guilds,
          shard: [_shard | _out_of],
          user_settings: _user_settings,
          v: v
        } = payload
      ) do
    Cache.init_app(app)
    Cache.init_bot(user)
    Logger.debug("#{inspect(payload, pretty: true)}")

    %WSState{socket | v: v, session_id: session_id}
  end

  def digest(%WSState{payload_dispatch_event: payload_dispatch_event} = socket, payload) do
    EventBroadcaster.digest({payload_dispatch_event, payload, socket})
    #  Logger.debug("#{inspect(payload_dispatch_event)}")
    socket
  end
end
