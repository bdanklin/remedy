defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false

  use Remedy.Gateway.Payload
  alias Remedy.Gateway.EventBroadcaster
  alias Remedy.Cache

  def digest(%Websocket{payload_dispatch_event: :READY} = socket, %{
        geo_ordered_rtc_regions: _geo_ordered_rtc_regions,
        presences: [],
        private_channels: [],
        relationships: [],
        session_id: session_id,
        application: app,
        user: user,
        guilds: guilds,
        shard: [_shard | _out_of],
        user_settings: _user_settings,
        v: v
      }) do
    Cache.initialize_app(app)
    Cache.initialize_bot(user)
    Cache.update_guilds(guilds)

    %Websocket{socket | v: v, session_id: session_id}
  end

  def digest(%Websocket{payload_dispatch_event: payload_dispatch_event} = socket, payload) do
    EventBroadcaster.digest({payload_dispatch_event, payload, socket})

    socket
  end
end
