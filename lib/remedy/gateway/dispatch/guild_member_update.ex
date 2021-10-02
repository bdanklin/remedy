defmodule Remedy.Gateway.Dispatch.GuildMemberUpdate do
  @moduledoc false

  alias Remedy.Schema.Member

  def handle({event, payload, socket}) do
    {event, Member.new(payload), socket}
  end
end
