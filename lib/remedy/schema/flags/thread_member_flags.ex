defmodule Remedy.Schema.ThreadMemberFlags do
  use Remedy.Flag

  defstruct NOTIFICATIONS: 1 <<< 0
end
