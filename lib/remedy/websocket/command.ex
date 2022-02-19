defmodule Remedy.Websocket.Command do
  @moduledoc false

  import Remedy.CaseHelpers,
    only: [to_pascal: 1]

  import Remedy.CastHelpers,
    only: [deep_blast: 1, deep_string_key: 1]

  def send(%{mod: mod, conn: conn, data_stream: data_stream} = socket, command, opts \\ []) do
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

    payload =
      %{
        "d" => payload,
        "op" => op_code_mod.to_integer(command)
      }
      |> deep_blast()
      |> deep_string_key()
      |> :erlang.term_to_binary()

    with :ok <- :gun.ws_send(conn, data_stream, {:binary, payload}) do
      socket
    end
  end
end
