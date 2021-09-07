defmodule Remedy.Shard.Supervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Cache.Mapping.GuildShard
  alias Remedy.CacheError
  alias Remedy.Shard
  alias Remedy.Shard.Session
  alias Remedy.Shard.Stage.{Cache, Producer}

  require Logger

  def start_link(_args) do
    {url, gateway_shard_count} = gateway()

    num_shards =
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
      [url, num_shards],
      name: ShardSupervisor
    )
  end

  def update_status(status, game, stream, type) do
    ShardSupervisor
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
  def init([url, num_shards]) do
    children =
      [
        Producer,
        Cache
      ] ++ for i <- 0..(num_shards - 1), do: create_worker(url, i)

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 3, max_seconds: 60)
  end

  @doc false
  def create_worker(gateway, shard_num) do
    Supervisor.child_spec(
      {Shard, [gateway, shard_num]},
      id: shard_num
    )
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
    case Api.request(:get, Constants.gateway_bot(), "") do
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
