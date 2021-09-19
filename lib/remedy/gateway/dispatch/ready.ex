defmodule Remedy.Gateway.Dispatch.Ready do
  @moduledoc false
  use Remedy.Schema

  embedded_schema do
    field :v, :integer
    embeds_one :user, User
    embeds_many :guilds, UnavailableGuild
    field :session_id, :string
    field :shard, {:array, :integer}
    embeds_one :application, App
  end

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

    {event, payload |> new(), socket}
  end
end
