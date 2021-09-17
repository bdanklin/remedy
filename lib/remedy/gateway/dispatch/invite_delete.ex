defmodule Remedy.Gateway.Dispatch.InviteDelete do
  @moduledoc false
  alias Remedy.Schema.Invite

  def handle({event, payload, socket}) do
    {event, payload |> Invite.new(), socket}
  end
end
