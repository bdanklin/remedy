defmodule Remedy.Gateway.Dispatch.MessageReactionRemoveAll do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache

  @primary_key false
  embedded_schema do
    field :message_id, Snowflake
    field :channel_id, Snowflake
    field :last_pin_timestamp, ISO8601
  end

  @doc false
  def handle({event, %{message_id: message_id} = payload, socket}) do
    Cache.remove_message_reactions(message_id)

    {event, payload |> new(), socket}
  end
end
