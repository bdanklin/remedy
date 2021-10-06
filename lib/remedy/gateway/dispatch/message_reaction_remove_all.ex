defmodule Remedy.Gateway.Dispatch.MessageReactionRemoveAll do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache
  alias Remedy.Schema.MessageReactionRemoveAll

  @doc false
  def handle({event, %{message_id: message_id} = payload, socket}) do
    Cache.remove_message_reactions(message_id)

    {event, payload |> MessageReactionRemoveAll.new(), socket}
  end
end
