defmodule Remedy.Voice.Session do
  @moduledoc false

  require Logger
  use GenServer
  alias Remedy.Websocket.Command
  alias Remedy.Websocket.Event
  alias Remedy.Websocket.Pacemaker
  alias Remedy.Voice.Session.State

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :"SHARD_#{opts[:shard]}")
  end

  def init(opts) do
    Logger.info("Starting Shard #{opts[:shard]}")

    {:ok,
     opts
     |> State.new(), {:continue, :establish_connection}}
  end

  def handle_continue(:establish_connection, socket) do
    {:noreply,
     socket
     |> State.open_websocket()}
  end

  ## Internal Heartbeat Timer Finished before Gateway ACK / RECONNECT
  def handle_info(:heartbeat, %State{heartbeat_ack: false} = socket) do
    Logger.warn("NO RESPONSE TO HEARTBEAT")

    {:noreply,
     socket
     |> State.close_websocket()
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
     |> State.close_websocket()
     |> Pacemaker.stop(), {:continue, :establish_connection}}
  end
end
