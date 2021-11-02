defmodule Remedy.Gateway.Dispatch.TypingStart do
  @moduledoc """

  """
  alias Remedy.Schema.TypingStart
  alias Remedy.Cache

  def handle({event, %{member: %{user: %{id: user_id}} = member, guild_id: guild_id} = payload, socket}) do
    member =
      member
      |> Map.put_new(:guild_id, guild_id)
      |> Map.put_new(:user_id, user_id)

    Cache.update_member(guild_id, user_id, member)

    typing_start =
      %{payload | member: member}
      |> Map.put(:timestamp, DateTime.from_unix!(payload.timestamp))
      |> TypingStart.form()
      |> IO.inspect()

    {event, typing_start, socket}
  end
end
