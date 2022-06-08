defmodule Remedy.Schema.CallbackDataFlags do
  use Remedy.Flag

  defstruct SUPPRESS_EMBEDS: 1 <<< 2,
            EPHEMERAL: 1 <<< 6
end
