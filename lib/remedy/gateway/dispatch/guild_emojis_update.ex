defmodule Remedy.Gateway.Dispatch.GuildEmojisUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, %{emojis: emojis, guild_id: guild_id} = payload, socket}) do
    for emoji <- emojis do
      %{emoji | guild_id: guild_id}
      |> Cache.update_emoji()
    end

    {event, payload, socket}
  end

  @moduledoc """
  Guild Emojis Update Event
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          emojis: Emoji.t()
        }

  embedded_schema do
    field :guild_id, Snowflake
    embeds_many :emojis, Emoji
  end
end
