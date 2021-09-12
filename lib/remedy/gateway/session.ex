defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.{Gun, GatewayATC}
  alias Remedy.Gateway.Websocket

  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{gateway: gateway, shard: shard}) do
    {:ok, %Websocket{gateway: gateway, shard: shard}, {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    {:noreply,
     socket
     |> GatewayATC.request_connect()
     |> Gun.open_await()
     |> Gun.upgrade_ws_await()
     |> Gun.zlib_init()}
  end

  ## Gun Messages

  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {:noreply, socket |> Payload.digest(frame)}
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

  ## Pacemaker Messages

  def handle_info(:HEARTBEAT, socket) do
    {:noreply,
     socket
     |> Pacemaker.start()}
  end

  def handle(%Websocket{payload_op_event: payload_op_event} = socket) do
    handle(payload_op_event, socket)
  end

  def handle(event, state) do
    Logger.warn("UNHANDLED GATEWAY EVENT #{event}")
    state
  end

  ################
  #### Handle Cast From API

  def handle_cast({:status_update, payload}, state) do
    :ok = :gun.ws_send(state.conn, state.stream, {:binary, payload})
    {:noreply, state}
  end

  def handle_cast({:update_voice_state, payload}, state) do
    :ok = :gun.ws_send(state.conn, state.stream, {:binary, payload})
    {:noreply, state}
  end

  def handle_cast({:request_guild_members, payload}, state) do
    :ok = :gun.ws_send(state.conn, state.stream, {:binary, payload})
    {:noreply, state}
  end

  ##############
  ##### Stuff to Uncomment and Fix

  # def update_status(pid, status, game, stream, type) do
  #   {idle_since, afk} =
  #     case status do
  #       "idle" ->
  #         {Util.now(), true}

  #       _ ->
  #         {0, false}
  #     end

  #   payload = Payload.status_update_payload(idle_since, game, stream, status, afk, type)
  #   GenServer.cast(pid, {:status_update, payload})
  # end

  # def update_voice_state(pid, guild_id, channel_id, self_mute, self_deaf) do
  # payload = Payload.update_voice_state_payload(guild_id, channel_id, self_mute, self_deaf)
  # GenServer.cast(pid, {:update_voice_state, payload})
  # end

  # def request_guild_members(pid, guild_id, limit \\ 0) do
  # payload = Payload.request_members_payload(guild_id, limit)
  # GenServer.cast(pid, {:request_guild_members, payload})
  # end
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
