defmodule Remedy.Schema.GuildEmojisUpdate do
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
