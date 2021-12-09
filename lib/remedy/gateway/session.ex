defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.{GatewayATC, Gun}
  alias Remedy.Gateway.{Pacemaker, Payload, WSState}
  import Remedy.OpcodeHelpers
  require Logger
  use GenServer

  def update_presence(shard, opts \\ []) do
    GenServer.cast(:"SESSION_#{shard}", {:status_update, opts})
  end

  def voice_status_update(shard, opts \\ []) do
    GenServer.cast(:"SESSION_#{shard}", {:update_voice_state, opts})
  end

  def request_guild_members(shard, opts \\ []) do
    GenServer.cast(:"SESSION_#{shard}", {:request_guild_members, opts})
  end

  @doc false
  def start_link(%{shard: shard} = opts) do
    GenServer.start_link(__MODULE__, opts, name: :"SESSION_#{shard}")
  end

  def init(%{shard: shard}) do
    {:ok, %WSState{shard: shard}, {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    {:noreply,
     socket
     |> GatewayATC.request_connect()
     |> Gun.open_websocket()}
  end

  def handle_cast({:status_update, opts}, socket) do
    Payload.send(socket, :STATUS_UPDATE, opts)
  end

  def handle_cast({:voice_status_update, opts}, socket) do
    Payload.send(socket, :VOICE_STATUS_UPDATE, opts)
  end

  def handle_cast({:request_guild_members, opts}, socket) do
    Payload.send(socket, :REQUEST_GUILD_MEMBERS, opts)
  end

  ## Internal Heartbeat Timer Finished before Gateway ACK
  ##
  def handle_info(:HEARTBEAT, %{heartbeat_ack: false} = socket) do
    Logger.warn("NO RESPONSE TO HEARTBEAT")

    {:noreply,
     socket
     |> Gun.close()
     |> Pacemaker.stop(), {:continue, :establish_connection}}
  end

  def handle_info(:HEARTBEAT, socket) do
    {:noreply,
     socket
     |> Payload.send(:HEARTBEAT)}
  end

  ## Data Frame Arrives
  ## Unzip with Zlib and build into the websocket state
  ##
  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, %WSState{zlib_context: zlib_context} = socket) do
    with payload <-
           :zlib.inflate(zlib_context, frame)
           |> :erlang.iolist_to_binary()
           |> :erlang.binary_to_term(),
         event <- event_from_op(payload[:op]) do
      {:noreply,
       %{
         socket
         | payload_op_code: payload[:op],
           payload_op_event: event,
           payload_sequence: payload[:s],
           payload_dispatch_event: payload[:t]
       }
       |> Payload.digest(event, payload[:d])}
    end
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, socket) do
    Logger.warn("WEBSOCKET CLOSED")
    {:noreply, socket}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, %{session_id: _session_id} = socket) do
    Logger.warn("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")
    Logger.warn("ATTEMPTING TO RECONNECT")

    {:noreply, socket |> Pacemaker.stop() |> Pacemaker.start() |> Payload.send(:RESUME)}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, socket) do
    Logger.warn("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")
    {:noreply, socket}
  end

  def handle_info({:gun_down, _conn, _stream, _, _}, socket) do
    Logger.warn("GUN DOWN")
    {:noreply, socket}
  end

  def handle_info({:gun_up, _worker, _proto}, %{session_id: session_id} = socket) when is_binary(session_id) do
    {:noreply, socket |> Pacemaker.stop() |> Pacemaker.start() |> Payload.send(:RESUME)}
  end

  def handle_info({:gun_up, _worker, _proto}, socket) do
    {:noreply, socket |> Gun.close() |> Pacemaker.stop(), {:continue, :establish_connection}}
  end
end
