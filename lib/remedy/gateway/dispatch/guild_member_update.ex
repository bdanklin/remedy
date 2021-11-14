defmodule Remedy.Gateway.Dispatch.GuildMemberUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{user: %{id: user_id} = user} = payload, socket}) do
    Cache.update_user(user)

    params = Map.put_new(payload, :user_id, user_id)

    case Cache.update_member(params) do
      {:ok, member} ->
        {event, member, socket}

      {:error, _changeset} ->
        :noop
    end
  end
end
