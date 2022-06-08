defmodule Remedy.Rest.Connection do
  @moduledoc false
  use GenServer
  require Logger

  alias Remedy.Rest.Connection.State

  @doc false

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: name(opts.worker))
  end

  def request(worker, request) do
    GenServer.call(name(worker), {:request, request})
  end

  defp name(worker), do: {:via, Registry, {Remedy.RestRegistry, worker}}

  @doc false
  def init(args) do
    Logger.debug(args)

    {:ok,
     State.new(args)
     |> State.handle_connect()}
  end

  def handle_call({:request, request}, _from, state) do
    {:reply,
     state
     |> State.handle_request(request), state}
  end

  def handle_info({:gun_error, _conn, _stream, error}, state) do
    {:noreply,
     state
     |> State.handle_error(error)}
  end

  def handle_info({:gun_down, _conn, _proto, _reason, _killed_streams}, state) do
    {:noreply,
     state
     |> State.handle_down()}
  end

  def handle_info({:gun_up, _conn, _proto}, state) do
    {:noreply,
     state
     |> State.handle_up()}
  end
end
