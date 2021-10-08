defmodule Remedy.Gateway.Dispatch.GuildMemberUpdate do
  @moduledoc false

  alias Remedy.Schema.GuildMemberUpdate

  def handle({event, payload, socket}) do
    {event, GuildMemberUpdate.new(payload), socket}
  end
end
