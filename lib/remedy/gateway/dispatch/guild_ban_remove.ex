defmodule Remedy.Gateway.Dispatch.GuildBanRemove do
  @moduledoc """
  Guild Ban Remove Event

  ## Payload

  - `%Remedy.Schema.Ban{}`

  """
  alias Remedy.{Cache, Util}

  def handle({event, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user}}, socket}) do
    Cache.update_user(user)

    case Cache.delete_ban(user_id, guild_id) do
      {:ok, ban} ->
        {event, ban, socket}

      _ ->
        Util.log_malformed(event)
        :noop
    end
  end
end
