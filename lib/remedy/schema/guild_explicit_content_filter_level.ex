defmodule Remedy.Schema.GuildExplicitContentFilter do
  use Remedy.Type
  defstruct DISABLED: 0, MEMBERS_WITHOUT_ROLES: 1, ALL_MEMBERS: 2
end
