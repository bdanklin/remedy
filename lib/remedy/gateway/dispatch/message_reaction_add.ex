defmodule Remedy.Gateway.Dispatch.MessageReactionAdd do
  @moduledoc false
  alias Remedy.Schema.Reaction

  @doc false
  def handle({event, payload, socket}) do
    {event, Reaction.new(payload), socket}
  end
end
