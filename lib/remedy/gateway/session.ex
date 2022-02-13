defmodule Remedy.Gateway.Session do
  @moduledoc false
  alias Remedy.Gateway.ATC
  alias Remedy.Gateway.Session.WSState
  alias Remedy.Websocket.Pacemaker
  alias Remedy.Websocket.Event
  alias Remedy.Websocket.Command
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :"SHARD_#{opts[:shard]}")
  end

  def init(opts) do
    Logger.info("Starting Shard #{opts[:shard]}")

    {:ok,
     opts
     |> WSState.new(), {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    with :ok <- ATC.request_connection(socket) do
      {:noreply,
       socket
       |> WSState.open_websocket()
       |> WSState.init_zlib()}
    end
  end

  def update_presence(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:status_update, opts})
  end

  def voice_state_update(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:voice_state_update, opts})
  end

  def request_guild_members(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:request_guild_members, opts})
  end

  def handle_cast({:voice_status_update, opts}, state) do
    {:noreply,
     state
     |> Command.send(:VOICE_STATUS_UPDATE, opts)}
  end

  ## Internal Heartbeat Timer Finished before Gateway ACK / RECONNECT
  def handle_info(:heartbeat, %WSState{heartbeat_ack: false} = socket) do
    Logger.warn("NO RESPONSE TO HEARTBEAT")

    {:noreply,
     socket
     |> WSState.close_websocket()
     |> Pacemaker.stop(), {:continue, :establish_connection}}
  end

  ## Send Heartbeat
  def handle_info(:heartbeat, socket) do
    {:noreply,
     socket
     |> Command.send(:HEARTBEAT)}
  end

  ## Data Frame Arrives
  ## Event Module will dispatch to appropriate event handler
  def handle_info({:gun_ws, _worker, _stream, {:binary, frame}}, socket) do
    {:noreply,
     socket
     |> Event.handle_frame(frame)}
  end

  def handle_info({:gun_ws, _conn, _stream, :close}, socket) do
    Logger.warn("WEBSOCKET CLOSED")
    Logger.warn("ATTEMPTING TO RECONNECT")

    {:noreply,
     socket
     |> Pacemaker.stop()
     |> Pacemaker.start()
     |> Command.send(:RESUME)}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, %{session_id: _session_id} = socket) do
    Logger.warn("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")
    Logger.warn("ATTEMPTING TO RECONNECT")

    {:noreply,
     socket
     |> Pacemaker.stop()
     |> Pacemaker.start()
     |> Command.send(:RESUME)}
  end

  def handle_info({:gun_ws, _conn, _stream, {:close, errno, reason}}, socket) do
    Logger.warn("WEBSOCKET CLOSED #{errno} #{inspect(reason)}")
    {:noreply, socket}
  end

  def handle_info({:gun_down, _conn, _stream, _, _}, socket) do
    Logger.warn("GUN DOWN")
    {:noreply, socket}
  end

  def handle_info({:gun_up, _worker, _proto}, %{session_id: _session_id} = state) do
    {:noreply,
     state
     |> Pacemaker.stop()
     |> Pacemaker.start()
     |> Command.send(:RESUME)}
  end

  def handle_info({:gun_up, _worker, _proto}, socket) do
    {:noreply,
     socket
     |> WSState.close_websocket()
     |> Pacemaker.stop(), {:continue, :establish_connection}}
  end
end
