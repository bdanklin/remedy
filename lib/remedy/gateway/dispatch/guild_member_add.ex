defmodule Remedy.Gateway.Dispatch.GuildMemberAdd do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Member{}.

  """
  alias Remedy.Cache

  def handle({event, %{user: user} = payload, socket}) do
    Cache.create_user(user)
    Cache.create_member(payload)

    {event, payload, socket}
  end
end
