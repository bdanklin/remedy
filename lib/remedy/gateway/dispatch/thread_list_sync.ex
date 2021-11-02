defmodule Remedy.Gateway.Dispatch.ThreadListSync do
  @moduledoc """
  Thread List Sync Event
  """

  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end
end
