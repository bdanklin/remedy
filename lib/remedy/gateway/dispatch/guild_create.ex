defmodule Remedy.Gateway.Dispatch.GuildCreate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """
  @large_threshold 250

  alias Remedy.Cache
  alias Remedy.Schema.{Channel, Guild, Member, User}

  def handle({event, %{id: guild_id, channels: channels, members: members} = payload, socket}) do
    guild =
      payload
      |> Map.put(:shard, socket.shard)
      |> Guild.new()
      |> Cache.create_guild()

    for member <- members do
      Member.new(member) |> Cache.create_member()
      User.new(member.user) |> Cache.create_user()
    end

    for channel <- channels do
      %{channel | guild_id: guild_id}
      |> Channel.new()
      |> Cache.create_channel()
    end

    {event, guild, socket}
  end
end
