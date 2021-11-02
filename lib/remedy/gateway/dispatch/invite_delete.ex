defmodule Remedy.Gateway.Dispatch.InviteDelete do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, %{code: code} = _payload, socket}) do
    with {:ok, invite} <- Cache.delete_invite(code) do
      {event, invite, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
