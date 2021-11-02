defmodule Remedy.Gateway.Dispatch.GuildMemberAdd do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{user: user} = payload, socket}) do
    Cache.update_user(user)

    with params <- add_fields(payload),
         {:ok, member} <- Cache.create_member(params) do
      {event, member, socket}
    end
  end

  defp add_fields(%{user: %{id: user_id}} = payload) do
    payload
    |> Map.put_new(:user_id, user_id)
  end
end
