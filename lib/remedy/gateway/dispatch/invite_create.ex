defmodule Remedy.Gateway.Dispatch.InviteCreate do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, payload, socket}) do
    with {:ok, invite} <- Cache.create_invite(payload) do
      {event, invite, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
