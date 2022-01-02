defmodule Remedy.Schema.GuildVerificationLevel do
  use Remedy.Type
  defstruct NONE: 0, LOW: 1, MEDIUM: 2, HIGH: 3, VERY_HIGH: 4
end
