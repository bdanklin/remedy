defmodule Remedy.Gateway.Dispatch.GuildBanRemove do
  @moduledoc false

  alias Remedy.Schema.Ban

  def handle({event, payload, socket}) do
    {event, Ban.new(payload), socket}
  end
end
