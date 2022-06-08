defmodule Remedy.Schema.ComponentType do
  use Remedy.Type

  defstruct ACTION_ROW: 1,
            BUTTON: 2,
            SELECT_MENU: 3,
            TEXT_INPUT: 4
end
