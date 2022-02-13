defmodule Remedy.Dispatch.Pipeline do
  @moduledoc false
  use Broadway
  alias Remedy.Dispatch.Producer
  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [module: {Producer, []}, concurrency: 1],
      processors: [
        default: [concurrency: 10]
      ]
    )
  end

  @impl Broadway
  @spec handle_message(any, Broadway.Message.t(), any) :: Broadway.Message.t()
  def handle_message(_processor, %Message{} = msg, _context) do
    msg
    |> internal_operations()
  end

  defp internal_operations(%Message{data: %{incoming: {event, payload, _socket}}} = message) do
    module = module_from_event(event)

    payload
    |> module.process()
    |> then(&put_in(message, [:data, :payload], &1))
  end

  defp module_from_event(event) do
    event
    |> Atom.to_string()
    |> Recase.to_pascal()
    |> String.to_atom()
    |> then(&Module.concat([Remedy, Dispatch, Payloads, &1]))
  end
end
