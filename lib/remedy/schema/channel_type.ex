defmodule Remedy.Schema.ChannelType do
  use Remedy.Type

  defstruct GUILD_TEXT: 0,
            DM: 1,
            GUILD_VOICE: 2,
            GROUP_DM: 3,
            GUILD_CATEGORY: 4,
            GUILD_NEWS: 5,
            GUILD_STORE: 6,
            GUILD_NEWS_THREAD: 7,
            GUILD_PUBLIC_THREAD: 8,
            GUILD_PRIVATE_THREAD: 9,
            GUILD_STAGE_VOICE: 10
end
