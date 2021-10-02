defmodule Remedy.Gateway.Dispatch.MessageReactionRemoveEmoji do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.MessageReactionRemoveEmoji
  @doc false
  def handle({event, %{message_id: message_id} = payload, socket}) do
    Cache.remove_message_reactions(message_id)

    {event, payload |> MessageReactionRemoveEmoji.new(), socket}
  end
end
