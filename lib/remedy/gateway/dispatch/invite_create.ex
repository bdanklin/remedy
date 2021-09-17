defmodule Remedy.Gateway.Dispatch.InviteCreate do
  @moduledoc false
  alias Remedy.Schema.Invite

  def handle({event, payload, socket}) do
    {event, payload |> Invite.new(), socket}
  end
end
