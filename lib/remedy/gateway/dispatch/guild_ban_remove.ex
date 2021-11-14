defmodule Remedy.Gateway.Dispatch.GuildBanRemove do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user}}, socket}) do
    with {:ok, _user} <- Cache.update_user(user),
         {:ok, ban} <- Cache.delete_ban(user_id, guild_id) do
      {event, ban, socket}
    else
      _ ->
        :noop
    end
  end
end
