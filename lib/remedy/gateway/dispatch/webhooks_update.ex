defmodule Remedy.Gateway.Dispatch.WebhooksUpdate do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
  end

  def handle({event, payload, socket}) do
    {event, payload |> new(), socket}
  end
end
