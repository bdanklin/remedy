defmodule Remedy.Websocket.Command do
  @moduledoc false

  import Remedy.CaseHelpers, only: [to_pascal: 1]

  def send(%{mod: mod} = socket, command, opts \\ []) do
    op_code_mod =
      [Remedy, mod, OPCode]
      |> Module.concat()

    handler =
      command
      |> op_code_mod.to_integer()
      |> op_code_mod.to_binary()
      |> to_pascal()
      |> String.to_atom()

    module =
      [Remedy, mod, Commands, handler]
      |> Module.concat()

    payload = module.send(socket, opts)

    %{
      "d" => payload,
      "op" => op_code_mod.to_integer(command)
    }
    |> Remedy.CastHelpers.deep_struct_blaster()
    |> Remedy.CastHelpers.deep_string_key()
    |> :erlang.term_to_binary()
    |> websocket_send(socket)
  end

  defp websocket_send(payload, %{conn: conn, data_stream: data_stream} = socket) do
    case :gun.ws_send(conn, data_stream, {:binary, payload}) do
      :ok -> socket
    end
  end
end
