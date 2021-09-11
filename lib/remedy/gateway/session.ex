defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.{Gun, GatewayATC}
  alias Remedy.Gateway.{Websocket, EventAdmission}
  import Remedy.{CommandHelpers, OpcodeHelpers}

  alias Remedy.Gateway.Commands.{
    Heartbeat,
    Hello,
    Identify,
    RequestGuildMembers,
    Resume,
    UpdatePresence,
    UpdateVoiceState
  }

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

  ###########################
  #### Gun Message Receivers
  ## These are events received by the gun worker.
  ## They are kinda ugly and I suppose this is the
  ## only place they should go

  def unpack_frame(%Websocket{zlib_context: zlib_context} = socket, frame) do
    %{socket | payload: :zlib.inflate(zlib_context, frame) |> :erlang.iolist_to_binary() |> :erlang.binary_to_term()}
    |> parse_opcode()
    |> parse_event()
    |> parse_sequence()
    |> parse_data()
    |> drop_payload()
  end

  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {:noreply,
     socket
     |> Gun.unpack_frame(frame)
     |> log_event("gun_ws")
     |> handle()}
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, state) do
    {:noreply,
     state
     |> log_event("WEBSOCKET CLOSED, UNKNOWN REASON")}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, state) do
    {:noreply,
     state
     |> log_event("WEBSOCKET CLOSED WITH ERROR: #{errno}, REASON: #{inspect(reason)}")}
  end

  def handle_info({:gun_down, _, _, _, _}, socket) do
    {:noreply,
     socket
     |> stop_the_heart()
     |> log_event("GUN DOWN")}
  end

  def handle_info({:gun_up, _worker, _proto}, socket) do
    {:noreply,
     socket
     |> log_event("RECONNECTED AFTER INTERRUPTION")}
  end

  #######################
  #### Pacemaker

  def handle_info(:HEARTBEAT, %{heartbeat_ack: false} = socket) do
    {:noreply,
     socket
     |> Gun.close()
     |> stop_the_heart()
     |> log_event("HEARTBEAT NOT ACKNOWLEDGED. RECONNECTING"), {:continue, :establish_connection}}
  end

  def handle_info(:HEARTBEAT, socket) do
    {:noreply,
     socket
     |> start_pacemaker()}
  end

  defp stop_the_heart(%Websocket{heartbeat_timer: heartbeat_timer} = socket) do
    :erlang.cancel_timer(heartbeat_timer)

    socket
  end

  defp start_pacemaker(%Websocket{heartbeat_interval: heartbeat_interval} = socket) do
    socket
    |> send_heartbeat()
    |> Map.put(:heartbeat_timer, Process.send_after(self(), :HEARTBEAT, heartbeat_interval))
    |> Map.put(:heartbeat_ack, false)
    |> Map.put(:last_heartbeat_send, DateTime.utc_now())
  end

  #######################
  #### Pacemaker

  def handle(socket)

  def handle(%Websocket{payload_event: payload_event} = socket), do: handle(payload_event, socket)

  # ⬇ OP CODE 1 - DISPATCH
  def handle(:DISPATCH, socket) do
    dispatch_digest(socket)

    socket
  end

  # ⬇ OP CODE 10 - DISPATCH
  # todo: If session exists, resume instead of identify
  def handle(:HELLO, %Websocket{payload_data: %{heartbeat_interval: heartbeat_interval}} = socket) do
    %Websocket{socket | heartbeat_interval: heartbeat_interval}
    |> log_event()
    |> start_pacemaker()
    |> send_identify()
    |> IO.inspect(label: "identify")
  end

  # ⬇ OP CODE 11 - HEARTBEAT_ACK - When the session is down. send identify
  def handle(:HEARTBEAT_ACK, %Websocket{heartbeat_ack: true, session_id: nil} = socket) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> send_identify()
    |> log_event(:HEARTBEAT_ACK)
    |> IO.inspect()
  end

  # ⬇ OP CODE 11 - HEARTBEAT_ACK
  def handle(:HEARTBEAT_ACK, socket) do
    %Websocket{socket | heartbeat_ack: true, last_heartbeat_ack: DateTime.utc_now()}
    |> log_event(:HEARTBEAT_ACK)
    |> IO.inspect()
  end

  # ⬇ OP CODE 9 - INVALID_SESSION
  def handle(:INVALID_SESSION, socket) do
    socket
    |> send_identify()
    |> log_event(:INVALID_SESSION)
  end

  def handle(:RECONNECT, socket) do
    socket
    |> send_identify()
    |> log_event(:RECONNECT)
  end

  def handle(:READY, socket) do
    socket
    |> IO.inspect()
  end

  def handle(event, state) do
    Logger.warn("UNHANDLED GATEWAY EVENT #{event}")
    state
  end

  #########
  ### Log Functions
  defp log_event(%{shard: shard, opcode: opcode, event: event} = socket, event) do
    Logger.debug("Shard: #{inspect(shard)} Opcode: #{inspect(opcode)} Reported: #{inspect(event)}")

    socket
  end

  defp log_event(%{shard: shard} = socket, event) do
    Logger.debug("Shard: #{inspect(shard)} #{inspect(event)}")

    socket
  end

  defp log_event(%{shard: shard, event: event} = socket) do
    Logger.debug("Shard: #{inspect(shard)}  Event: #{inspect(event)}")

    socket
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

  def send_heartbeat(socket, opts \\ []), do: Heartbeat.payload(socket, opts) |> Gun.send()
  def send_identify(socket, opts \\ []), do: Identify.payload(socket, opts) |> IO.inspect() |> Gun.send()
  def send_request_guild_members(socket, opts \\ []), do: RequestGuildMembers.payload(socket, opts)
  def send_resume(socket, opts \\ []), do: Resume.payload(socket, opts)
  def send_update_presence(socket, opts \\ []), do: UpdatePresence.payload(socket, opts)
  def send_update_voice_state(socket, opts \\ []), do: UpdateVoiceState.payload(socket, opts)
end

defmodule Remedy.Gateway.SessionSupervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Gateway.Session

  def start_link(%{shard: shard} = opts) do
    Supervisor.start_link(__MODULE__, opts, name: :"Shard-#{shard}")
  end

  def init(opts) do
    children = [
      {Session, opts}
    ]

    Supervisor.init(children, strategy: :one_for_all, max_restarts: 3, max_seconds: 60)
  end
end
