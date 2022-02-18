defmodule Remedy.Websocket.Event do
  @moduledoc false
  defstruct op_code: nil,
            sequence: nil,
            dispatch_event: nil,
            payload: nil

  require Logger

  defp new(payload) do
    %__MODULE__{
      op_code: payload[:op],
      sequence: payload[:s],
      dispatch_event: payload[:t],
      payload: payload[:d]
    }
  end

  def handle_frame(%{zlib: zlib, shard: shard} = socket, frame) do
    with unzipped_frame <-
           :zlib.inflate(zlib, frame)
           |> :erlang.iolist_to_binary() do
      try do
        :erlang.binary_to_term(unzipped_frame, [:safe])
      rescue
        ArgumentError ->
          with pre_atoms <- :erlang.system_info(:atom_count),
               payload <- :erlang.binary_to_term(unzipped_frame),
               post_atoms <- :erlang.system_info(:atom_count),
               new_atoms <- post_atoms - pre_atoms do
            if post_atoms > pre_atoms do
              atoms = for i <- pre_atoms..(post_atoms - 1), do: :erlang.binary_to_term(<<131, 75, i::24>>)

              Logger.warn(
                "Shard: #{shard} created #{new_atoms} new atoms while unpacking frame. OP:#{payload[:op]}, SEQ: #{payload[:s]}, DISPATCH: #{payload[:t]}\n
#{inspect(atoms)}"
              )
            end

            payload
          end
      end
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
      |> Remedy.CaseHelpers.to_pascal()
      |> String.to_atom()

    module =
      [Remedy, mod, Events, handler]
      |> Module.concat()

    apply(module, :digest, [socket, payload])
  end
end
