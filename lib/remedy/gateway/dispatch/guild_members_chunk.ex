defmodule Remedy.Gateway.Dispatch.GuildMemberChunk do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Member{}.

  """
  use Remedy.Schema

  embedded_schema do
    field :guild_id, :integer
    embeds_many :members, Member
    embeds_many :presences, Presence
    field :chunk_index, :integer
    field :chunk_count, :integer
    field :not_found, {:array, :string}
    field :nonce, :string
  end

  alias Remedy.Cache

  def handle({event, %{members: members, presences: presences} = payload, socket}) do
    for member <- members do
      Member.new(member) |> Cache.create_member()
      User.new(member.user) |> Cache.create_user()
    end

    for presence <- presences do
      Presence.new(presence) |> Cache.create_presence()
      User.new(presence.user) |> Cache.create_user()
    end

    {event, new(payload), socket}
  end
end
