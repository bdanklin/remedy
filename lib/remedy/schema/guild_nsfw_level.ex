defmodule Remedy.Schema.GuildNSFWLevel do
  use Remedy.Type

  defstruct DEFAULT: 0,
            EXPLICIT: 1,
            SAFE: 2,
            AGE_RESTRICTED: 3
end
