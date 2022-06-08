defmodule Remedy.Gateway.Session do
  @moduledoc false
  use GenServer

  alias Remedy.Gateway.Session.WSState

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :"SHARD_#{opts[:shard]}")
  end

  @doc false
  def init(opts) do
    {:ok,
     opts
     |> WSState.new(), {:continue, :connect}}
  end

  @doc false
  def handle_continue(:connect, socket) do
    {:noreply,
     socket
     |> WSState.handle_connect()}
  end

  ## Pacemaker Events
  def handle_info(:pacemaker, socket) do
    {:noreply,
     socket
     |> WSState.handle_pacemaker()}
  end

  ## Websocket Events
  def handle_info({:gun_ws, _worker, _stream, payload}, socket) do
    {:noreply,
     socket
     |> WSState.handle_ws(payload)}
  end

  ## Unexpected Outage
  def handle_info({:gun_down, _conn, _stream, _, _}, socket) do
    {:noreply,
     socket
     |> WSState.handle_down()}
  end

  ## Connection Restored
  def handle_info({:gun_up, _worker, _proto}, socket) do
    {:noreply,
     socket
     |> WSState.handle_up(), {:continue, :connect}}
  end

  ############################################################################
  ## Optional Payloads #######################################################
  ############################################################################

  def presence_update(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:presence_update, opts})
  end

  def voice_state_update(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:voice_state_update, opts})
  end

  def request_guild_members(shard, opts \\ []) do
    GenServer.cast(:"SHARD_#{shard}", {:request_guild_members, opts})
  end

  def handle_cast({:presence_update, opts}, socket) do
    {:noreply,
     socket
     |> WSState.handle_presence_update(opts)}
  end

  def handle_cast({:voice_state_update, opts}, socket) do
    {:noreply,
     socket
     |> WSState.handle_voice_state_update(opts)}
  end

  def handle_cast({:request_guild_members, opts}, socket) do
    {:noreply,
     socket
     |> WSState.handle_request_guild_members(opts)}
  end
end
