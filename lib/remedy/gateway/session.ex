defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.{Gun, GatewayATC}
  alias Remedy.Gateway.{Pacemaker, Payload, Websocket}
  import Remedy.OpcodeHelpers
  require Logger
  use GenServer

  def update_presence(shard, opts \\ []) do
    GenServer.cast(:"Shard-#{shard}", {:status_update, opts})
  end

  def voice_status_update(shard, opts \\ []) do
    GenServer.cast(:"Shard-#{shard}", {:update_voice_state, opts})
  end

  def request_guild_members(shard, opts \\ []) do
    GenServer.cast(:"Shard-#{shard}", {:request_guild_members, opts})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{gateway: gateway, shard: shard}) do
    {:ok, %Websocket{gateway: gateway, shard: shard}, {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    {:noreply, socket |> GatewayATC.request_connect() |> Gun.open_await() |> Gun.upgrade_ws_await() |> Gun.zlib_init()}
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

  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {payload, socket} = Gun.unpack_frame(socket, frame)
    Logger.debug("#{payload["t"]}")

    {:noreply,
     %Websocket{
       socket
       | payload_op_code: payload.op,
         payload_op_event: op_event(payload.op),
         payload_sequence: payload["seq"],
         payload_data: payload["d"],
         payload_dispatch_event: payload["t"]
     }
     |> Payload.digest(op_event(payload.op), payload["d"])}
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, state) do
    Logger.debug("WEBSOCKET CLOSED")
    {:noreply, state}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, state) do
    Logger.debug("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")
    {:noreply, state}
  end

  def handle_info({:gun_down, _conn, _stream, _, _}, socket) do
    Logger.debug("GUN DOWN")
    {:noreply, socket}
  end

  def handle_info({:gun_up, _worker, _proto}, socket) do
    Logger.debug("RECONNECTED AFTER INTERRUPTION")
    {:noreply, socket}
  end

  def handle_info(:HEARTBEAT, %{heartbeat_ack: false} = socket) do
    Logger.debug("NO RESPONSE TO HEARTBEAT")

    {:noreply,
     socket
     |> Gun.close()
     |> Pacemaker.stop(), {:continue, :establish_connection}}
  end

  def handle_info(:HEARTBEAT, %{heartbeat_ack: true} = socket) do
    Logger.debug("LUB")

    {:noreply,
     socket
     |> Payload.send(:HEARTBEAT)
     |> Pacemaker.start()}
  end
end

defmodule Remedy.Gateway.SessionSupervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Gateway.Session

  def start_link(%{shard: shard} = opts) do
    Supervisor.start_link(__MODULE__, opts, name: :"Shard-#{shard}")
  end

  def init(opts) do
    children = [{Session, opts}]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 3, max_seconds: 60)
  end
end
