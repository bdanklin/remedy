defmodule Remedy.Schema.InviteTargetType do
  use Remedy.Type

  defstruct STREAM: 1,
            EMBEDDED_APPLICATION: 2
end
