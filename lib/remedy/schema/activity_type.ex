defmodule Remedy.Schema.ActivityType do
  use Remedy.Type

  defstruct GAME: 0,
            STREAMING: 1,
            LISTENING: 2,
            WATCHING: 3,
            CUSTOM: 4,
            COMPETING: 5,
            UNKNOWN: 6
end
