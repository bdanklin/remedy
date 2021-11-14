defmodule Remedy.Gateway.Dispatch.InviteDelete do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{code: code} = _payload, socket}) do
    with {:ok, invite} <- Cache.delete_invite(code) do
      {event, invite, socket}
    else
      {:error, _reason} ->
        :noop
    end
  end
end
