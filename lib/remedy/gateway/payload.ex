defmodule Remedy.Gateway.Payload do
  @moduledoc false

  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      import Remedy.OpcodeHelpers
      use Ecto.Schema
      alias Remedy.Gun
      alias Remedy.Gateway.{Pacemaker, Payload, Session, WSState}
      @dialyzer {:no_missing_calls, :"Elixir.Gun", websocket_send: 2}

      def build_payload(socket, opts), do: payload(socket, opts) |> send_out()
      defp send_out(%WSState{} = socket), do: socket

      defp send_out({payload, socket}) do
        %{
          "d" => crush(payload),
          "op" => op_from_mod(__MODULE__)
        }
        |> flatten()
        |> :erlang.term_to_binary()
        |> Gun.websocket_send(socket)
      end

      defp crush(map), do: map |> flatten() |> Morphix.stringmorphiform!()
      defp flatten(map), do: :maps.map(&dfl/2, map)
      defp dfl(_key, value), do: enm(value)
      defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
      defp enm(%{__struct__: _} = strct), do: :maps.map(&dfl/2, Map.from_struct(strct))
      defp enm(data), do: data
      @before_compile Payload
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def digest(socket, payload), do: socket
      def payload(socket, payload), do: socket
      defoverridable(digest: 2, payload: 2)
    end
  end

  @typedoc false
  @type payload :: any | nil
  @typedoc false
  @type socket :: WSState.t()
  @typedoc false
  @type opts :: list() | nil

  @doc false
  @callback payload(socket, opts) :: {payload, socket}

  @doc false
  @callback digest(socket, payload) :: socket

  @optional_callbacks payload: 2, digest: 2

  alias Remedy.Gateway.{Events, WSState}

  alias Remedy.Gateway.Events.{
          Dispatch,
          HeartbeatAck,
          Heartbeat,
          Hello,
          Identify,
          InvalidSession,
          Reconnect,
          RequestGuildMembers,
          Resume,
          StatusUpdate,
          SyncCall,
          SyncGuild,
          UpdatePresence,
          VoiceStatusUpdate,
          VoiceStatusUpdate
        },
        warn: false

  import Remedy.{ModelHelpers, OpcodeHelpers}

  require Logger

  @spec digest(WSState.t(), any, binary) :: WSState.t()
  def digest(socket, event, payload) do
    Logger.debug("#{inspect(event)}")
    module_delegate(event).digest(socket, payload)
  end

  @spec send(WSState.t(), any, any) :: any
  def send(socket, event, opts \\ []) when is_op_event(event) do
    Logger.debug("#{inspect(event)}")
    module_delegate(event).build_payload(socket, opts)
  end

  defp module_delegate(event) do
    [Events, mod_from_event(event)] |> Module.concat()
  end
end
