defmodule Remedy.Schema.CallbackDataFlags do
  use Remedy.Flag

  defstruct EPHEMERAL: 1 <<< 6
end
