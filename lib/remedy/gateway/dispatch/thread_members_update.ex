defmodule Remedy.Gateway.Dispatch.ThreadMembersUpdate do
  @moduledoc false
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    {event, Channel.new(payload), socket}
  end
end
