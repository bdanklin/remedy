defmodule Remedy.Gateway.Dispatch.ChannelPinsUpdate do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          last_pin_timestamp: ISO8601.t()
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :last_pin_timestamp, ISO8601
  end

  def handle({event, payload, socket}) do
    %{
      id: payload.channel_id,
      guild_id: payload.guild_id,
      last_pin_timestamp: payload.last_pin_timestamp
    }
    |> Cache.update_channel()

    {event, new(payload), socket}
  end
end
