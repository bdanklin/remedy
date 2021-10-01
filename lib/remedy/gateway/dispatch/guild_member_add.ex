defmodule Remedy.Gateway.Dispatch.GuildMemberAdd do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{user: user} = payload, socket}) do
    Cache.create_user(user)
    Cache.create_member(payload)

    {event, payload, socket}
  end
end
