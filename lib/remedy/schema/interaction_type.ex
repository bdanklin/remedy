defmodule Remedy.Schema.InteractionType do
  use Remedy.Type

  defstruct PING: 1,
            APPLICATION_COMMAND: 2,
            MESSAGE_COMPONENT: 3,
            APPLICATION_COMMAND_AUTOCOMPLETE: 4,
            MODAL_SUBMIT: 5
end
