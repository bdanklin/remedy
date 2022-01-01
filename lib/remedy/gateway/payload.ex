defmodule Remedy.Gateway.Payload do
  @moduledoc false
  alias Remedy.Gateway.WSState

  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      alias unquote(parent)
      alias Remedy.Gateway.{Gun, Pacemaker, Payload, Session, WSState}
      import Remedy.OpcodeHelpers, only: [op_from_mod: 1]
      import :erlang, only: [term_to_binary: 1]
      import Remedy.Gateway.Gun, only: [websocket_send: 2]
      use Ecto.Schema

      def build_payload(socket, opts), do: payload(socket, opts) |> send_out()
      defp send_out(%WSState{} = socket), do: socket

      defp send_out({payload, socket}) do
        %{
          "d" => payload,
          "op" => op_from_mod(__MODULE__)
        }
        |> flatten()
        |> term_to_binary()
        |> websocket_send(socket)
      end

      defp flatten(map), do: :maps.map(&dfl/2, map) |> Morphix.stringmorphiform!()
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

  ## Each event is handled by its own module
  ##
  ## If an event is received on the gateway, mod.digest/2 is invoked.
  ## It needs to return the socket modified as required by the event.
  ##
  ## If an event is to be sent mod.payload/2 is invoked.
  ## It needs to return a tuple of {payload_to_send, socket}

  @doc false
  @callback payload(socket, opts) :: {payload, socket}

  @doc false
  @callback digest(socket, payload) :: socket

  @optional_callbacks payload: 2, digest: 2

  import Remedy.OpcodeHelpers, only: [is_op_event: 1, mod_from_event: 1]
  require Logger
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

  @spec digest(WSState.t(), any, binary) :: WSState.t()
  def digest(socket, event, payload) do
    module_delegate(event).digest(socket, payload)
  end

  @spec send(WSState.t(), any, any) :: any
  def send(socket, event, opts \\ []) do
    module_delegate(event).build_payload(socket, opts)
  end

  defp module_delegate(event) when is_op_event(event) do
    #  Logger.info("#{event}")
    [Events, mod_from_event(event)] |> Module.concat()
  end
end
