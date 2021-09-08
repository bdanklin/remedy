defmodule Remedy.Shard.AirTrafficControl do
  @moduledoc """
  Controls the runway for shard connections.
  """

  use GenServer
  require Logger
  import Remedy.TimeHelpers

  @min_redial 5500

  def request_connect do
    GenServer.call(__MODULE__, {:request_connect}, :infinity)
  end

  def handle_call({:request_connect}, _from, state) do
    {:reply, :ok,
     state
     |> dial()
     |> wait()
     |> connect()}
  end

  defp dial(state) when state in [nil, 0], do: state
  defp dial(last_connect), do: utc_now_ms() - last_connect

  defp wait(state) when state in [nil, 0], do: :ok
  defp wait(time_diff) when time_diff >= @min_redial, do: :ok

  defp wait(time_diff), do: (@min_redial - time_diff) |> log_and_wait()

  defp log_and_wait(wait_time) do
    Logger.warn("WAITING #{wait_time} BEFORE CONNECTING WEBSOCKET")
    Process.sleep(wait_time)
  end

  defp connect(:ok), do: utc_now_ms()

  ############
  ### Genserver
  ############

  def start_link(_args) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end
end
