defmodule Remedy.Gateway.Dispatch.GuildBanAdd do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user, reason: reason}}, socket}) do
    params = %{user_id: user_id, guild_id: guild_id, reason: reason}

    with {:ok, _user} <- Cache.update_user(user),
         {:ok, ban} <- Cache.update_ban(params) do
      {event, ban, socket}
    else
      {:error, _reason} ->
        :noop
    end
  end
end
