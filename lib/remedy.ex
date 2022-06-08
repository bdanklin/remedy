defmodule Remedy do
  require Logger

  @dialyzer :no_match

  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @moduledoc readme
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias Remedy.Buffer
  alias Remedy.Consumer
  alias Remedy.Dispatch
  alias Remedy.Gateway
  alias Remedy.Rest
  alias Remedy.Repo
  alias Remedy.Voice

  @doc """
  Returns the current version of Remedy.
  """
  def version do
    Keyword.get(Remedy.MixProject.project(), :version)
  end

  @doc """
  Returns the current repo URL of Remedy.
  """
  def scm_url do
    Keyword.get(Remedy.MixProject.project(), :source_url)
  end

  ############################################################################
  ## Start Application
  ##
  use Application

  @doc false
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    with args <- build_args(),
         kids <- build_children(args) do
      validate_token(args)
      Supervisor.start_link(kids, restart: :permenant, strategy: :one_for_one)
    end
  end

  defp build_children(%{embedded: false}), do: []
  defp build_children(%{embedded: true} = args), do: children(args)

  defp validate_token(%{embedded: true, token: <<_::192, 46, _::48, 46, _::216>>}), do: :ok
  defp validate_token(%{embedded: true, token: _}), do: raise("INVALID TOKEN CONFIGURATION")
  defp validate_token(%{embedded: false}), do: :ok

  ############################################################################
  ## Start Supervised
  ##
  use Supervisor

  @doc "Starts an instance of `Remedy` supervised by the current process."
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def init(args) do
    with args <- build_args(args),
         children <- children(args) do
      Supervisor.init(children, strategy: :one_for_one)
    end
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  ############################################################################
  ## Configuration
  ##
  @doc false
  @env Mix.env()
  def env, do: @env

  @rest_v 10
  @gateway_v 9
  @voice_v 6

  @defaults %{
    embedded: true,
    token: nil,
    secret: nil,
    intents: :auto,
    shards: :auto,
    workers: :auto,
    cache: :auto,
    debug: false,
    id: __MODULE__,
    env: :dev,
    rest_v: @rest_v,
    gateway_v: @gateway_v,
    voice_v: @voice_v
  }

  defp build_args(args \\ %{}) do
    dotenv_args()
    |> Map.merge(env_args())
    |> Map.merge(config_args())
    |> Map.merge(args)
    |> Map.put_new(:env, @env)
    |> filter_nils()
    |> Enum.into(@defaults)
    |> Map.take(Map.keys(@defaults))
  end

  defp children(args) do
    keys = Map.keys(@defaults)

    args =
      args
      |> Map.take(keys)
      |> Enum.into([])

    [
      ## RESTful API
      {Rest, args},
      ## Cache
      {Repo, args},
      ## Event Processing
      {Consumer, args},
      {Buffer, args},
      {Dispatch, args},
      ## Gateway
      {Gateway, args},
      {Voice, args}
    ]
  end

  #############################################################################
  ## .env File
  ##
  @dotenv_args [
    embedded: "REMEDY_EMBEDDED",
    token: "REMEDY_TOKEN",
    secret: "REMEDY_SECRET",
    intents: "REMEDY_INTENTS",
    shards: "REMEDY_SHARDS",
    workers: "REMEDY_WORKERS"
  ]
  @dotenv_vars Keyword.values(@dotenv_args)
  @doc false
  defp dotenv_args do
    try do
      File.read!("./.env")
      |> String.split("\n")
      |> Enum.filter(&String.starts_with?(&1, "export "))
      |> Enum.map(&String.trim_leading(&1, "export "))
      |> Enum.filter(&String.starts_with?(&1, @dotenv_vars))
      |> Enum.map(&String.split(&1, "="))
      |> Enum.reduce(%{}, fn
        [k, v], acc ->
          Map.put_new(acc, atomize_env_key(k), v)
      end)
      |> Enum.map(&clean_arg/1)
      |> Enum.into(%{})
    rescue
      File.Error -> %{}
    end
    |> filter_nils()
  end

  defp atomize_env_key(arg) when arg in @dotenv_vars do
    arg
    |> String.downcase()
    |> String.split("_")
    |> List.last()
    |> String.to_atom()
  end

  #############################################################################
  ## Environment Variables
  ##
  @env_args [
    embedded: "REMEDY_EMBEDDED",
    token: "REMEDY_TOKEN",
    secret: "REMEDY_SECRET",
    intents: "REMEDY_INTENTS",
    shards: "REMEDY_SHARDS",
    workers: "REMEDY_WORKERS"
  ]
  @doc false
  defp env_args do
    for {key, env} <- @env_args, into: [] do
      {key, System.get_env(env)}
    end
    |> Enum.map(&clean_arg/1)
    |> filter_nils()
  end

  #############################################################################
  ## Config
  ##
  @config_args [
    :embedded,
    :token,
    :secret,
    :intents,
    :shards,
    :workers,
    :cache,
    :debug,
    :id
  ]
  @doc false
  defp config_args do
    for key <- @config_args, into: [] do
      {key, Application.get_env(:remedy, key, nil)}
    end
    |> Enum.map(&clean_arg/1)
    |> filter_nils()
  end

  #############################################################################
  ## Parser
  ##
  defp clean_arg({arg, nil}), do: {arg, nil}
  defp clean_arg({:embedded, value}), do: {:embedded, value |> String.trim("\"") |> parse_bool()}
  defp clean_arg({:token, value}), do: {:token, value |> String.trim("\"")}
  defp clean_arg({:secret, value}), do: {:secret, value |> String.trim("\"")}
  defp clean_arg({:intents, value}), do: {:intents, value |> String.trim("\"") |> parse_auto_or_int()}
  defp clean_arg({:workers, value}), do: {:workers, value |> String.trim("\"") |> parse_auto_or_int()}
  defp clean_arg({:shards, value}), do: {:shards, value |> String.trim("\"") |> parse_auto_or_int()}

  defp filter_nils(map) do
    Enum.reduce(map, %{}, fn
      {_k, nil}, acc -> acc
      {k, v}, acc -> Map.put_new(acc, k, v)
    end)
  end

  defp parse_bool(bool) when bool in ['true', 'TRUE', "true", "TRUE", 1, "1", true], do: true
  defp parse_bool(bool) when bool in ['false', 'FALSE', "false", "FALSE", 0, "0", false], do: false

  defp parse_auto_or_int(arg) when arg in ["auto", "AUTO", 'auto', 'AUTO', :auto], do: :auto
  defp parse_auto_or_int(arg) when is_binary(arg), do: String.to_integer(arg)
  defp parse_auto_or_int(arg), do: arg
end
