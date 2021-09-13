defmodule Remedy.Gateway.Payload do
  @moduledoc """
  Payload represents the data packet set to discord through the API. All processing of the payload should be done within this context as it will be cleared upon returning to the session process.

  > These functions exist to attempt friendly discourse with the ill mannered Discord gateway. Documentation is included for completeness but using them is at your peril!

  ## Fields

  - `op:` Opcode.
  - `d:`  Data.
  - `s:`  Sequence.
  - `t:`  Event Name.

  ## Sending

  ### `send/2`

  Any event that will be delivered to discord must contain a `send/2` function. It is given the socket and a keyword list of options, and returns just the payload data. This will be dispatched upon receiving an event of the module name converted to **discord** case.

  For example: if the session receives a message of `:HEARTBEAT`. The socket will immediately be passed to `Payload.Heartbeat.send/2`. Therefore the `%Websocket{}` struct must contain all of the required information to return the heartbeat. **Once the payload has been sent, the payload field will be cleared.**

  The only requirement of `payload/2` is that it returns the payload data. the other fields will automatically be calculated. The `HeartbeatAck` module simply returns the

  ## Receiving

  ### `intake/2`

  Some payloads coming from discord should be immediately decoded and their information added to the socket. For each of these data types an `intake/2` function should be included

  Mappings to use these functions are provided from within the `Remedy.Gateway` module.

  ## Dispatching

  Events that are dispatched to our consumer will generally require more expenisve processing, such as caching etc. This

  Modules that `use Payload` will have their data packed and passed to this function through the `send` callback.

  The callback described above is only required to return the raw data. It is further
  """

  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      alias unquote(parent)
      import Remedy.OpcodeHelpers
      use Ecto.Schema
      alias Remedy.Gun
      alias Remedy.Gateway.{Payload, Websocket}

      @before_compile
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def build_payload(socket, opts) do
        payload(socket, opts)
        |> send_out()
      end

      defp crush(map), do: map |> flatten() |> Morphix.stringmorphiform!()
      defp flatten(map), do: :maps.map(&dfl/2, map)
      defp dfl(_key, value), do: enm(value)
      defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
      defp enm(%{__struct__: _} = strct), do: :maps.map(&dfl/2, Map.from_struct(strct))
      defp enm(data), do: data

      def payload(socket, opts) do
        {nil, socket}
      end

      defp send_out({nil, socket}) do
        socket
      end

      defp send_out({payload, socket}) do
        payload
        |> prep_payload()
        |> Gun.send(socket)
      end

      def digest(socket, payload), do: socket

      defp prep_payload(payload) do
        %{
          "d" => crush(payload),
          "op" => op_from_mod()
        }
        |> flatten()
        |> :erlang.term_to_binary()

        defoverridable(payload: 2, digest: 2)
      end
    end
  end

  @type payload :: any
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
  import Remedy.{ModelHelpers, OpcodeHelpers}
  require Logger

  @doc """
  Digest the data frame into the socket.

  Delegates the digestion to the appropriate module. It is that modules responsibility to implement the `digest/2` callback and return the `%Websocket{}`
  """
  @spec digest(Websocket.t(), any, binary) :: Websocket.t()
  def digest(socket, event, payload),
    do: Module.concat([event]).digest(socket, payload)

  @doc """
  Sends a command based on the current websocket state.

  Using this will invoke the appropriate modules
  """
  @spec send(Websocket.t(), any, any) :: any
  def send(socket, event, opts \\ []) when is_op_event(event) do
    Module.concat([event]).build_payload(socket, opts)
  end
end
