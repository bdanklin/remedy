defmodule Remedy.Dispatch.Pipeline do
  @moduledoc false
  use Broadway
  alias Remedy.Dispatch.Producer
  alias Broadway.Message
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
    IO.inspect("""
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    """)

    Remedy.Consumer.Producer.ingest(message)
    message
  end

  # defp payload_module_from_event(event) do
  # event
  # |> Atom.to_string()
  # |> Recase.to_pascal()
  # |> String.to_atom()
  # |> then(&Module.concat([Remedy, Dispatch, Payloads, &1]))
  # end
end
