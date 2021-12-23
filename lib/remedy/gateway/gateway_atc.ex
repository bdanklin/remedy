defmodule Remedy.GatewayATC do
  @moduledoc false

  use GenServer
  require Logger

  @min_redial 5500

  def request_connect(state) do
    case GenServer.call(__MODULE__, {:request_connect}, :infinity) do
      :ok -> state
    end
  end

  ############
  ### GenServer
  ############

  def start_link(_args) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  @doc false
  def handle_call({:request_connect}, _from, state) do
    {:reply, :ok,
     state
     |> dial()
     |> wait()
     |> connect()}
  end

  defp dial(state) when state in [nil, 0], do: state
  defp dial(last_connect), do: now() - last_connect

  defp wait(state) when state in [nil, 0], do: :ok
  defp wait(time_diff) when time_diff >= @min_redial, do: :ok
  defp wait(time_diff), do: (@min_redial - time_diff) |> log_and_wait()

  defp log_and_wait(wait_time) do
    Logger.warn("WAITING #{wait_time} BEFORE CONNECTING WSState")

    format = [
      bar_color: [IO.ANSI.green_background()],
      blank_color: [IO.ANSI.red_background()],
      bar: " ",
      blank: " ",
      left: " ",
      right: " "
    ]

    Enum.each(1..wait_time, fn i ->
      ProgressBar.render(i, wait_time, format)
      :timer.sleep(1)
    end)
  end

  defp connect(:ok), do: now()

  defp now, do: System.os_time(:millisecond)
end
