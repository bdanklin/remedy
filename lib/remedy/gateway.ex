defmodule Remedy.Gateway do
  @moduledoc false

  use Supervisor

  alias Remedy.Shard
  alias Remedy.Gateway.{EventAdmission, EventBuffer, Session, ShardSupervisor}

  require Logger

  @gateway "/gateway"
  @gateway_bot "/gateway/bot"

  def start_link(_args) do
    {url, gateway_shard_count} = gateway()

    shards =
      case Application.get_env(:remedy, :num_shards, :auto) do
        :auto ->
          gateway_shard_count

        ^gateway_shard_count ->
          gateway_shard_count

        shard_count when is_integer(shard_count) and shard_count > 0 ->
          Logger.warn(
            "Configured shard count (#{shard_count}) " <>
              "differs from Discord Gateway's recommended shard count (#{gateway_shard_count}). " <>
              "Consider using `num_shards: :auto` option in your Remedy config."
          )

          shard_count

        value ->
          raise ~s("#{value}" is not a valid shard count)
      end

    Supervisor.start_link(
      __MODULE__,
      %{url: url, shards: shards},
      name: __MODULE__
    )
  end

  def update_status(status, game, stream, type) do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.filter(fn {_id, _pid, _type, [modules]} -> modules == Remedy.Shard end)
    |> Enum.map(fn {_id, pid, _type, _modules} -> Supervisor.which_children(pid) end)
    |> List.flatten()
    |> Enum.map(fn {_id, pid, _type, _modules} ->
      Session.update_status(pid, status, game, stream, type)
    end)
  end

  # def update_voice_state(guild_id, channel_id, self_mute, self_deaf) do
  #   case GuildShard.get_shard(guild_id) do
  #     {:ok, shard_id} ->
  #       ShardSupervisor
  #       |> Supervisor.which_children()
  #       |> Enum.filter(fn {_id, _pid, _type, [modules]} -> modules == Remedy.Shard end)
  #       |> Enum.filter(fn {id, _pid, _type, _modules} -> id == shard_id end)
  #       |> Enum.map(fn {_id, pid, _type, _modules} -> Supervisor.which_children(pid) end)
  #       |> List.flatten()
  #       |> Enum.filter(fn {_id, _pid, _type, [modules]} -> modules == Remedy.Shard.Session end)
  #       |> List.first()
  #       |> elem(1)
  #       |> Session.update_voice_state(guild_id, channel_id, self_mute, self_deaf)

  #     {:error, :id_not_found} ->
  #       raise CacheError, key: guild_id, cache_name: GuildShardMapping
  #   end
  # end

  @doc false
  def init(%{url: url, shards: shards}) do
    children =
      [
        EventAdmission,
        EventBuffer
      ] ++ shard_workers(url, shards)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  defp shard_workers(gateway, shards), do: for(shard <- 0..(shards - 1), into: [], do: shard_worker(gateway, shard))

  defp shard_worker(gateway, shard),
    do: Supervisor.child_spec({ShardSupervisor, %{gateway: gateway, shard: shard}}, id: shard)

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
        body = Poison.decode!(body)

        "wss://" <> url = body["url"]
        shards = if body["shards"], do: body["shards"], else: 1

        :ets.insert(:gateway_url, {"url", url, shards})
        {url, shards}
    end
  end
end

defmodule Remedy.GatewayATC do
  @moduledoc """
  Gateway Air Traffic Control
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
  ### Genserver
  ############

  def start_link(_args) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end
end

defmodule Remedy.GatewayStatus do
  @moduledoc """
  Simple cache that stores information for the current user.
  """

  use Agent
  use Remedy.Schema

  def start_link(%{}) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  @doc ~S"""
  Returns the current user's state.
  """
  @spec get() :: User.t() | nil
  def get do
    Agent.get(__MODULE__, fn user -> user end)
  end

  def put(%User{} = user) do
    Agent.update(__MODULE__, fn _ -> user end)
  end

  def update(%{} = values) do
    Agent.update(__MODULE__, fn state ->
      struct(state, values)
    end)
  end

  def delete do
    Agent.update(__MODULE__, fn _ -> nil end)
  end
end
