defmodule Remedy.Gateway.Payload do
  @moduledoc """
  Payload represents the data packet set to discord through the API. All processing of the payload should be done within this context as it will be cleared upon returning to the session process.

  > These functions exist to attempt friendly discourse with the ill mannered Discord gateway. Documentation is included for completeness but using them is at your peril!

  ## Fields

  - `op:` Opcode.
  - `d:`  Data.
  - `s:`  Sequence.
  - `t:`  Event Name.


  """

  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      import Remedy.OpcodeHelpers
      use Ecto.Schema
      alias Remedy.Gateway.{Pacemaker, Payload, Session, Websocket}

      def build_payload(socket, opts), do: payload(socket, opts) |> send_out()
      defp send_out(%Websocket{} = socket), do: socket

      defp send_out({payload, socket}) do
        %{
          "d" => crush(payload),
          "op" => op_from_mod(__MODULE__)
        }
        |> flatten()
        |> :erlang.term_to_binary()
        |> Remedy.Gun.send(socket)
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

  @type payload :: any | nil
  @type socket :: Websocket.t()
  @type opts :: list() | nil

  @doc """
  Describes how to take the current socket state and construct the payload data for this modules event type.

  For example: `Heartbeat.send/2` will take the socket, and a keyword list of options, and construct the payload data for the event of type `:HEARTBEAT`. It is the responsibility of the developer to ensure that all events required to be sent implement this function.

  If the behaviour is not described. Passing this function will just pass the socket back to session to continue doing what it do.
  """
  @callback payload(socket, opts) :: {payload, socket}

  @doc """
  Digest the data frame from Discord and loads the data into the socket. For example:

  - The `:heartbeat_ack` flag on the websocket needs to be set to true once the `:HEARTBEAT_ACK` event is received from discord.

  In short. Do what you need to do with the payload. because its going away
  """
  @callback digest(socket, payload) :: socket

  @optional_callbacks payload: 2, digest: 2

  alias Remedy.Gateway.Websocket

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

  @doc """
  Digest the data frame into the socket.

  Delegates the digestion to the appropriate module. It is that modules responsibility to implement the `digest/2` callback and return the `%Websocket{}`
  """
  @spec digest(Websocket.t(), any, binary) :: Websocket.t()
  def digest(socket, event, payload),
    do: module_delegate(event).digest(socket, payload)

  @doc """
  Sends a command based on the current websocket state.

  Using this will invoke the appropriate modules
  """
  @spec send(Websocket.t(), any, any) :: any
  def send(socket, event, opts \\ []) when is_op_event(event) do
    module_delegate(event).build_payload(socket, opts)
  end

  defp module_delegate(event) do
    [Remedy.Gateway.Events, mod_from_event(event)]
    |> Module.concat()
  end
end
