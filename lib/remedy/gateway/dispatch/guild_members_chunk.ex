defmodule Remedy.Gateway.Dispatch.GuildMemberChunk do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.{GuildMembersChunk, Member, User}

  def handle({event, payload, socket}) do
    payload =
      payload
      |> GuildMembersChunk.new()

    handle_guild_member_chunk(payload)
    {event, payload, socket}
  end

  defp handle_guild_member_chunk(%GuildMembersChunk{members: members, presences: presences}) do
    for member <- members do
      Cache.upsert_user(member.user)
      Cache.create_member(member)
    end

    for presence <- presences do
      Cache.upsert_user(presence.user)
    end
  end
end
