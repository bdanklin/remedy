defmodule Remedy.Gateway.Dispatch.InviteCreate do
  @moduledoc false

  def handle({event, payload, socket}) do
    with {:ok, invite} <- Remedy.Cache.update_invite(payload) do
      {event, invite, socket}
    else
      {:error, _reason} ->
        :noop
    end
  end
end
