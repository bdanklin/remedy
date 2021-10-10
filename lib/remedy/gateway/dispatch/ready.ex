defmodule Remedy.Gateway.Dispatch.Ready do
  @moduledoc false
  alias Remedy.Schema.Ready

  def handle(
        {event,
         %{
           v: _v,
           user: _user,
           guilds: _guilds,
           session_id: _session_id,
           shard: [_shard_id | _num_shards],
           application: _application
         } = payload, socket}
      ) do
    #  Gateway.process_ready(v, session_id, shard_id, num_shards)
    #   Cache.put_bot(user)
    #   Cache.put_app(application)

    {event, payload, socket}
  end
end
