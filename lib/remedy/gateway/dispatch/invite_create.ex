defmodule Remedy.Gateway.Dispatch.InviteCreate do
  @moduledoc false
  alias Remedy.Schema.InviteCreate

  def handle({event, payload, socket}) do
    {event, payload |> InviteCreate.new(), socket}
  end
end
