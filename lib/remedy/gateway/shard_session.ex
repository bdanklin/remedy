defmodule Remedy.Gateway.ShardSession do
  @moduledoc false

  alias Remedy.Util
  alias Remedy.Gateway.Websocket
  alias Remedy.Shard.{Event, Payload}
  alias Remedy.{Gun, GatewayATC}
  require Logger

  use GenServer

  @gateway_qs "/?compress=zlib-stream&encoding=etf&v=6"
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
     |> Gun.zlib_init()
     |> put_gateway()
     |> ack_heartbeats()
     |> log_connection_up()}
  end

  defp put_gateway(%Websocket{gateway: gateway} = socket) do
    %{socket | gateway: gateway <> @gateway_qs}
  end

  defp ack_heartbeats(socket) do
    %{socket | heartbeat_ack: true}
  end

  defp log_connection_up(%Websocket{shard: shard, worker: worker} = socket) do
    Logger.metadata(shard: shard)
    Logger.info("Connection Established for shard: #{inspect(shard)}, on worker: #{inspect(worker)}", shard: shard)
    socket
  end

  defp unpack_frame_to_payload(%{zlib_context: zlib_context} = state, frame) do
    %{state | payload: :zlib.inflate(zlib_context, frame) |> :erlang.iolist_to_binary() |> :erlang.binary_to_term()}
  end

  defp parse_payload(%{payload: %{op: op}} = socket) do
    %{socket | opcode: op}
  end

  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {:noreply,
     socket
     |> unpack_frame_to_payload(frame)
     |> parse_payload()
     |> IO.inspect()
     |> Event.handle()}
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, state) do
    Logger.info("Shard websocket closed (unknown reason)")
    {:noreply, state}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, state) do
    Logger.info("Shard websocket closed (errno #{errno}, reason #{inspect(reason)})")
    {:noreply, state}
  end

  def handle_info({:gun_down, _conn, _proto, _reason, _killed_streams}, state) do
    # Try to cancel the internal timer, but
    # do not explode if it was already cancelled.
    :timer.cancel(state.heartbeat_ref)
    {:noreply, state}
  end

  def handle_info({:gun_up, _worker, _proto}, state) do
    Logger.warn("Reconnected after connection broke")
    {:noreply, %{(state |> Gun.upgrade_ws_await()) | heartbeat_ack: true}}
  end

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

  def handle_cast(:heartbeat, %{heartbeat_ack: false, heartbeat_ref: timer_ref} = state) do
    Logger.warn("heartbeat_ack not received in time, disconnecting")
    {:ok, :cancel} = :timer.cancel(timer_ref)
    :gun.ws_send(state.conn, state.stream, :close)
    {:noreply, state}
  end

  def handle_cast(:heartbeat, state) do
    {:ok, ref} = :timer.apply_after(state.heartbeat_interval, :gen_server, :cast, [state.conn_pid, :heartbeat])

    :ok = :gun.ws_send(state.conn, state.stream, {:binary, Payload.heartbeat_payload(state.sequence)})

    {:noreply, %{state | heartbeat_ref: ref, heartbeat_ack: false, last_heartbeat_send: DateTime.utc_now()}}
  end

  def handle_call(:get_ws_state, _sender, state) do
    {:reply, state, state}
  end

  ###########
  ### Remove
  ###########

  def update_status(pid, status, game, stream, type) do
    {idle_since, afk} =
      case status do
        "idle" ->
          {Util.now(), true}

        _ ->
          {0, false}
      end

    payload = Payload.status_update_payload(idle_since, game, stream, status, afk, type)
    GenServer.cast(pid, {:status_update, payload})
  end

  def update_voice_state(pid, guild_id, channel_id, self_mute, self_deaf) do
    payload = Payload.update_voice_state_payload(guild_id, channel_id, self_mute, self_deaf)
    GenServer.cast(pid, {:update_voice_state, payload})
  end

  def request_guild_members(pid, guild_id, limit \\ 0) do
    payload = Payload.request_members_payload(guild_id, limit)
    GenServer.cast(pid, {:request_guild_members, payload})
  end

  def get_ws_state(pid) do
    GenServer.call(pid, :get_ws_state)
  end
end
