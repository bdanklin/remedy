defmodule Remedy.Gateway.Dispatch.GuildMemberChunk do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.{GuildMembersChunk, Member, Presence, User}

  def handle({event, %{members: members, presences: presences} = payload, socket}) do
    for member <- members do
      Member.new(member) |> Cache.create_member()
      User.new(member.user) |> Cache.create_user()
    end

    for presence <- presences do
      Presence.new(presence) |> Cache.create_presence()
      User.new(presence.user) |> Cache.create_user()
    end

    {event, GuildMembersChunk.new(payload), socket}
  end
end
