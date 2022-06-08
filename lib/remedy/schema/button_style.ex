defmodule Remedy.Schema.ButtonStyle do
  use Remedy.Type

  defstruct PRIMARY: 1,
            SECONDARY: 2,
            SUCCESS: 3,
            DANGER: 4,
            LINK: 5
end
