defmodule Remedy.Gateway do
  @moduledoc false

  use Supervisor
  alias Remedy.Gateway.{EventBroadcaster, EventBuffer, SessionSupervisor}
  require Logger

  @gateway_bot "/gateway/bot"

  def start_link(_args) do
    {url, gateway_shard_count} = gateway()

    Supervisor.start_link(__MODULE__, %{url: url, shards: gateway_shard_count}, name: __MODULE__)
  end

  @doc false
  def init(%{url: url, shards: shards}) do
    children =
      [
        EventBroadcaster,
        EventBuffer
      ] ++ shard_workers(url, shards)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp shard_workers(gateway, shards),
    do: for(shard <- 0..(shards - 1), into: [], do: shard_worker(gateway, shard))

  defp shard_worker(gateway, shard),
    do: Supervisor.child_spec({SessionSupervisor, %{gateway: gateway, shard: shard}}, id: shard)

  def num_shards do
    gateway() |> Tuple.to_list() |> List.last()
  end

  @doc """
  Returns the gateway url and shard count for current websocket connections.

  If by chance no gateway connection has been made, will fetch the url to use and store it
  for future use.
  """
  @spec gateway() :: {String.t(), integer}
  def gateway do
    case :ets.lookup(:gateway_url, "url") do
      [] -> get_new_gateway_url()
      [{"url", url, shards}] -> {url, shards}
    end
  end

  defp get_new_gateway_url do
    case Remedy.Api.request(:get, @gateway_bot, "") do
      {:error, %{status_code: 401}} ->
        raise("Authentication rejected, invalid token")

      {:error, %{status_code: code, message: message}} ->
        raise(Remedy.ApiError, status_code: code, message: message)

      {:ok, body} ->
        body = Jason.decode!(body)

        "wss://" <> url = body["url"]
        shards = if body["shards"], do: body["shards"], else: 1

        :ets.insert(:gateway_url, {"url", url, shards})
        {url, shards}
    end
  end
end

defmodule Remedy.GatewayATC do
  @moduledoc false

  use GenServer
  require Logger
  import Remedy.TimeHelpers

  @min_redial 5500

  def request_connect(state) do
    case GenServer.call(__MODULE__, {:request_connect}, :infinity) do
      :ok -> state
    end
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

  defp connect(:ok), do: utc_now_ms()

  ############
  ### GenServer
  ############

  def start_link(_args) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end
end
