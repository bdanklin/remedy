defmodule Remedy.Gateway.Session.WSState do
  @moduledoc false
  ############################################################################
  ## Sessions are unique by shard, shards, token, intents
  ##
  ## For example, if one server is getting absolutely hammered with presence.
  ## We can start a session particularly for that servers presence_update
  ## events (and in turn, a broadway worker for that shard)
  ##
  ## If starting these does not overlap we will lose events.
  ##
  ## The buffer does not mind taking duplicate events. However we will still
  ## not start multiple identical sessions. Cuase thats just stupid.

  require Logger

  alias Remedy.Gateway.Commands
  alias Remedy.Gateway.Events

  @opaque t :: %{}

  defstruct mod: Gateway,
            id: nil,
            conn: nil,
            data_stream: nil,
            zlib: nil,
            ## Session
            v: nil,
            token: nil,
            session_id: nil,
            intents: nil,
            shard: nil,
            shards: nil,
            ## Websocket Opts
            port: 443,
            url: 'gateway.discord.gg',
            gateway_opts: %{
              compress: :"zlib-stream",
              encoding: :etf,
              v: 9
            },
            conn_opts: %{
              protocols: [:http],
              retry: 3,
              ws_opts: %{keepalive: 5000},
              tls_opts: []
            },
            ## Heartbeat
            heartbeat: 0,
            heartbeat_timer: nil,
            heartbeat_ack: nil,
            heartbeat_interval: nil,
            heartbeat_last_ack: nil,
            heartbeat_last_send: nil,
            ## Payload
            payload_dispatch_event: nil,
            payload_op_code: nil,
            payload_sequence: nil

  def new(args) do
    %__MODULE__{
      token: args.token,
      shard: args[:shard],
      shards: args[:shards],
      intents: args[:intents]
    }
  end

  def handle_connect(%__MODULE__{session_id: nil} = socket) do
    socket
    |> request_connection()
    |> open_websocket()
    |> init_zlib()
    |> Commands.send(:IDENTIFY)
    |> Commands.send(:HEARTBEAT)
    |> start_pacemaker()
  end

  def handle_connect(%__MODULE__{} = socket) do
    socket
    |> open_websocket()
    |> Commands.send(:RESUME)
    |> Commands.send(:HEARTBEAT)
    |> start_pacemaker()
  end

  alias Remedy.Gateway.ATC

  defp request_connection(socket) do
    ATC.request_connection(socket)
  end

  defp init_zlib(%__MODULE__{zlib: _} = socket) do
    with zlib <- :zlib.open(),
         :ok <- :zlib.inflateInit(zlib) do
      %__MODULE__{socket | zlib: zlib}
    end
  end

  ############################################################################
  ## Pacemaker
  ##

  ## No Ack To Last Heartbeat
  def handle_pacemaker(%__MODULE__{heartbeat_ack: false} = socket) do
    socket
    |> close_websocket()
    |> open_websocket()
    |> Commands.send(:RESUME)
    |> start_pacemaker()
  end

  ## No Ack To Last Heartbeat
  def handle_pacemaker(%__MODULE__{} = socket) do
    socket
    |> Commands.send(:HEARTBEAT)
  end

  defp start_pacemaker(%{heartbeat_interval: heartbeat_interval, heartbeat: heartbeat} = socket) do
    %{
      socket
      | heartbeat_timer: Process.send_after(self(), :pacemaker, heartbeat_interval),
        heartbeat_ack: true,
        heartbeat_last_send: DateTime.utc_now(),
        heartbeat: heartbeat + 1
    }
  end

  defp stop_pacemaker(%{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)
    %{socket | heartbeat: 0}
  end

  defp ack_heartbeat(socket) do
    %{socket | heartbeat_ack: true, heartbeat_last_ack: DateTime.utc_now()}
  end

  ############################################################################
  ## Optional Payloads
  def handle_presence_update(%__MODULE__{} = socket, opts) do
    socket
    |> Commands.send(:PRESENCE_UPDATE, opts)
  end

  def handle_voice_state_update(%__MODULE__{} = socket, opts) do
    socket
    |> Commands.send(:VOICE_STATE_UPDATE, opts)
  end

  def handle_request_guild_members(%__MODULE__{} = socket, opts) do
    socket
    |> Commands.send(:REQUEST_GUILD_MEMBERS, opts)
  end

  ###########################################################################

  def handle_ws(%__MODULE__{} = socket, {:binary, frame}) do
    socket
    |> Event.handle_frame(frame)
  end

  def handle_ws(%__MODULE__{} = socket, :close) do
    Logger.warn("WEBSOCKET CLOSED ABRUPTLY")
    Logger.warn("ATTEMPTING TO RECONNECT")

    socket
    |> Pacemaker.stop()
    |> Pacemaker.start()
    |> Command.send(:RESUME)
  end

  def handle_ws(%__MODULE__{} = socket, {:close, errno, reason}) do
    Logger.warn("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")

    socket
  end

  ## Connection Unavailable ( Unexpected Outage, Not Closed )
  def handle_down(%__MODULE__{} = socket) do
    Logger.warn("WEBSOCKET DOWN")

    socket
    |> stop_pacemaker()
  end

  def handle_up(%__MODULE__{} = socket) do
    socket
  end

  ############################################################################
  ## Websocket Commands

  defp open_websocket(
         %__MODULE__{
           gateway_opts: gateway_opts,
           conn_opts: conn_opts,
           port: port,
           url: url
         } = socket
       ) do
    gateway_opts =
      URI.encode_query(gateway_opts, :rfc3986)
      |> then(&Kernel.<>("/?", &1))
      |> :erlang.binary_to_list()

    conn_opts = %{
      conn_opts
      | tls_opts: [
          verify: :verify_peer,
          cacerts: :certifi.cacerts(),
          depth: 3,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
    }

    with {:ok, conn} <- :gun.open(url, port, conn_opts),
         {:ok, :http} <- :gun.await_up(conn, 10_000),
         data_stream <- :gun.ws_upgrade(conn, gateway_opts),
         {:upgrade, ["websocket"], _} <- :gun.await(conn, data_stream, 10_000) do
      %__MODULE__{socket | conn: conn, data_stream: data_stream}
    end
  end

  defp close_websocket(%__MODULE__{conn: conn, data_stream: data_stream} = socket) do
    with :ok <- :gun.ws_send(conn, data_stream, :close) do
      socket
    end
  end
end
