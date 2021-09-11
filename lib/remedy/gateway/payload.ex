defmodule Remedy.Gateway.Payload do
  alias Remedy.Gateway.Websocket
  import Remedy.{ModelHelpers, OpcodeHelpers}

  @doc """
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


  """

  defmacro __using__(_) do
    quote do
      import Remedy.{EventHelpers, OpcodeHelpers}
      use Ecto.Schema

      alias Remedy.Gateway.{Payload, Websocket}

      alias Remedy.Gateway.Events.{
        Heartbeat,
        Hello,
        Identify,
        RequestGuildMembers,
        Resume,
        UpdatePresence,
        UpdateVoiceState
      }

      @before_compile
    end
  end

  defmacro __before_compile__(_env) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      def send(socket, opts, default \\ []),
        do: Payload.send({command_from_module(), send(socket, opts || default)}, socket)

      def send(socket, opts \\ []), do: :noop

      def digest(socket, payload \\ nil) do
        socket
        |> digest(payload)
        |> Payload.digest()
      end

      def digest(socket, nil), do: socket
      def digest(socket, payload), do: :noop

      defoverridable(send: 2, digest: 2)
    end
  end

  @type socket :: Websocket.t()
  @type opts :: list() | nil

  @doc """
  Describes how to take the current socket state and construct the payload data for this modules event type.

  For example: `Heartbeat.send/2` will take the socket, and a keyword list of options, and construct the payload data for the event of type `:HEARTBEAT`. It is the responsibility of the developer to ensure that all events required to be sent implement this function.

  If the behaviour is not described. Passing this function will just pass the socket back to session to continue doing what it do.
  """
  @callback send(socket, opts) :: any()

  @doc """
  Digest the data frame from Discord and loads the data into the socket. For example:

  - The `:heartbeat_ack` flag on the websocket needs to be set to true once the `:HEARTBEAT_ACK` event is received from discord.

  This function is responsible for shit like that.
  """
  @callback digest(socket) :: socket

  @doc """
  Modules that `use Payload` will have their data packed and passed to this function through the `send` callback.

  The callback described above is only required to return the raw data. It is further
  """

  @optional_callbacks send: 2, digest: 1
  def send({:noop, _payload}, socket), do: socket

  def send({command, payload}, socket) do
    %{
      "d" => payload,
      "op" => op_code(command)
    }
    |> flatten()
    |> :erlang.term_to_binary()
    |> Gun.send(socket)
  end

  defp flatten(map), do: :maps.map(&do_flatten/2, map)
  defp do_flatten(_key, value), do: enm(value)
  defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
  defp enm(%{__struct__: _} = strct), do: :maps.map(&do_flatten/2, Map.from_struct(strct))
  defp enm(data), do: data
end
