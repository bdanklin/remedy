defmodule Remedy.Gateway.Payload do
  @moduledoc false

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

  @typedoc false
  @type payload :: any | nil
  @typedoc false
  @type socket :: Websocket.t()
  @typedoc false
  @type opts :: list() | nil

  ##   Describes how to take the current socket state and construct the payload data for this modules event type.
  ##   For example: `Heartbeat.send/2` will take the socket, and a keyword list of options, and construct the payload data for the event of type `:HEARTBEAT`. It is the responsibility of the developer to ensure that all events required to be sent implement this function.
  ##   If the behaviour is not described. Passing this function will just pass the socket back to session to continue doing ## what it do.
  @doc false
  @callback payload(socket, opts) :: {payload, socket}

  @doc false
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

  # delegates to {Command}.digest

  @spec digest(Websocket.t(), any, binary) :: Websocket.t()
  def digest(socket, event, payload),
    do: module_delegate(event).digest(socket, payload)

  ## delegates to command.send. eg calling `Payload.send(:READY)` will send a properly constructed ready command to discord.

  ## Due to some functions requiring additional parameters that cannot be preconfigured, external API functionality is provided through the Gateway module. ( maybe )

  @spec send(Websocket.t(), any, any) :: any
  def send(socket, event, opts \\ []) when is_op_event(event) do
    module_delegate(event).build_payload(socket, opts)
  end

  defp module_delegate(event) do
    [Remedy.Gateway.Events, mod_from_event(event)]
    |> Module.concat()
  end
end
