defmodule Remedy.Dispatch.Pipeline do
  @moduledoc false
  use Broadway
  alias Remedy.Dispatch.Producer
  require Logger

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Producer, []},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor, message, _context) do
    push_message_to_consumer(message)

    message
  end

  defp push_message_to_consumer(%Broadway.Message{metadata: %{event: event, socket: socket}, data: payload}) do
    Remedy.Consumer.Producer.ingest({event, payload, socket})
  end
end
