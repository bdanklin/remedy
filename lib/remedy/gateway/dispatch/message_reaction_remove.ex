defmodule Remedy.Gateway.Dispatch.MessageReactionRemove do
  @moduledoc false
  alias Remedy.Schema.Reaction

  def handle({event, payload, socket}) do
    {event, Reaction.new(payload), socket}
  end
end
