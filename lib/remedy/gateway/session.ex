defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.{GatewayATC, Gun}
  alias Remedy.Gateway.{Pacemaker, Payload, WSState}
  import Remedy.OpcodeHelpers
  require Logger
  use GenServer

  ### External

  def update_presence(shard, opts \\ []) do
    GenServer.cast(:"Session-#{shard}", {:status_update, opts})
  end

  def voice_status_update(shard, opts \\ []) do
    GenServer.cast(:"Session-#{shard}", {:update_voice_state, opts})
  end

  def request_guild_members(shard, opts \\ []) do
    GenServer.cast(:"Session-#{shard}", {:request_guild_members, opts})
  end

  ### Internal

  def start_link(%{shard: shard} = opts) do
    GenServer.start_link(__MODULE__, opts, name: :"Session-#{shard}")
  end

  def init(%{gateway: gateway, shard: shard}) do
    {:ok, %WSState{gateway: gateway, shard: shard}, {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    {:noreply,
     socket
     |> GatewayATC.request_connect()
     |> Gun.open_websocket()
     |> Gun.zlib_init()}
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

  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {payload, socket} = Gun.unpack_frame(socket, frame)

    {:noreply,
     %WSState{
       socket
       | payload_op_code: payload.op,
         payload_op_event: event_from_op(payload.op),
         payload_sequence: payload[:s],
         payload_dispatch_event: payload[:t]
     }
     |> Payload.digest(event_from_op(payload.op), payload[:d])}
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, state) do
    Logger.warn("WSState CLOSED")
    {:noreply, state}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, state) do
    Logger.warn("WSState CLOSED #{errno} #{inspect(reason)}")
    {:noreply, state}
  end

  def handle_info({:gun_down, _conn, _stream, _, _}, socket) do
    Logger.warn("GUN DOWN")
    {:noreply, socket}
  end

  def handle_info({:gun_up, _worker, _proto}, socket) do
    Logger.info("RECONNECTED AFTER INTERRUPTION")
    {:noreply, socket}
  end
end
