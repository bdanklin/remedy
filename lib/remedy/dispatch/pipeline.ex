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
        default: [concurrency: 10, min_demand: 1, max_demand: 2]
      ]
    )
  end

  @impl Broadway
  @spec handle_message(any, Message.t(), any) :: Message.t()
  def handle_message(
        _processor,
        %Message{} = message,
        _context
      ) do
    Logger.error("""
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    MADE IT TO BROADWAY PIPELINE
    """)

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
