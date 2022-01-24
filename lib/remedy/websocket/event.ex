defmodule Remedy.Websocket.Event do
  @moduledoc false
  defstruct op_code: nil, sequence: nil, dispatch_event: nil, payload: nil

  def handle_frame(%{zlib: zlib} = socket, frame) do
    with payload <-
           :zlib.inflate(zlib, frame)
           |> :erlang.iolist_to_binary()
           |> :erlang.binary_to_term() do
      payload
      |> new()
      |> handle_event(socket)
    end
  end

  def handle_frame(socket, frame) do
    with payload <-
           frame
           |> :erlang.iolist_to_binary()
           |> :erlang.binary_to_term() do
      payload
      |> new()
      |> handle_event(socket)
    end
  end

  defp new(payload) do
    %__MODULE__{
      op_code: payload[:op],
      sequence: payload[:s],
      dispatch_event: payload[:t],
      payload: payload[:d]
    }
  end

  defp handle_event(event, socket) do
    socket
    |> put_event_data(event)
    |> delegate_digest(event)
  end

  defp put_event_data(socket, event) do
    %{
      socket
      | payload_op_code: event.op_code,
        payload_sequence: event.sequence,
        payload_dispatch_event: event.dispatch_event
    }
  end

  defp delegate_digest(%{mod: mod} = socket, %__MODULE__{op_code: op_code, payload: payload}) do
    op_code_mod =
      [Remedy, mod, OPCode]
      |> Module.concat()

    handler =
      op_code
      |> op_code_mod.to_binary()
      |> Recase.to_pascal()
      |> String.to_atom()

    module =
      [Remedy, mod, Events, handler]
      |> Module.concat()

    apply(module, :digest, [socket, payload])
  end
end
