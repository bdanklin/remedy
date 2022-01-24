defmodule Remedy.Websocket.Command do
  @moduledoc false
  def send(%{mod: mod} = socket, command, opts \\ []) do
    op_code_mod =
      [Remedy, mod, OPCode]
      |> Module.concat()

    handler =
      command
      |> op_code_mod.to_integer()
      |> op_code_mod.to_binary()
      |> Recase.to_pascal()
      |> String.to_atom()

    module =
      [Remedy, mod, Commands, handler]
      |> Module.concat()

    payload = module.send(socket, opts)

    %{
      "d" => payload,
      "op" => op_code_mod.to_integer(command)
    }
    |> flatten()
    |> :erlang.term_to_binary()
    |> websocket_send(socket)
  end

  defp flatten(map), do: :maps.map(&dfl/2, map) |> Morphix.stringmorphiform!()
  defp dfl(_key, value), do: enm(value)
  defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
  defp enm(%{__struct__: _} = strct), do: :maps.map(&dfl/2, Map.from_struct(strct))
  defp enm(data), do: data

  defp websocket_send(payload, %{conn: conn, data_stream: data_stream} = socket) do
    case :gun.ws_send(conn, data_stream, {:binary, payload}) do
      :ok -> socket
    end
  end
end
