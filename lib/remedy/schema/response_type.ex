defmodule Remedy.Schema.ResponseType do
  use Remedy.Type

  defstruct PONG: 1,
            CHANNEL_MESSAGE_WITH_SOURCE: 4,
            DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE: 5,
            DEFERRED_UPDATE_MESSAGE: 6,
            APPLICATION_UPDATE: 7,
            APPLICATION_COMMAND_AUTOCOMPLETE_RESULT: 8
end
