defmodule Remedy.Gateway.Dispatch.GuildBanAdd do
  @moduledoc """
  Guild Ban Add Event

  ## Payload

  - `%Remedy.Schema.Ban{}`

  """

  alias Remedy.{Cache, Util}

  def handle({event, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user, reason: reason}}, socket}) do
    params = %{user_id: user_id, guild_id: guild_id, reason: reason}

    with {:ok, _user} <- Cache.update_user(user),
         {:ok, ban} <- Cache.update_ban(params) do
      {event, ban, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
