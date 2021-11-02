defmodule Remedy.Gateway.Dispatch.GuildMemberUpdate do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, %{user: %{id: user_id} = user, guild_id: guild_id} = payload, socket}) do
    Cache.update_user(user)

    params = Map.put_new(payload, :user_id, user_id)

    case Cache.update_member(guild_id, user_id, params) do
      {:ok, member} ->
        {event, member, socket}

      {:error, _changeset} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
