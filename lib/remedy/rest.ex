defmodule Remedy.Rest do
  @moduledoc false

  use Supervisor

  alias Remedy.Rest.Connection
  alias Remedy.Rest.Request
  alias Remedy.Rest.Response
  alias Remedy.Rest.Lifeguard
  alias Remedy.Rest.Pool

  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    args = Keyword.take(args, [:workers, :token])

    children = [
      {Registry, keys: :unique, name: Remedy.RestRegistry},
      {Pool, []},
      {Lifeguard, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def request(method, route, params, query, reason, body) do
    Logger.warn("made it here")

    Request.new(method, route, params, query, reason, body)
    |> request()
  end

  defp request(request, retry \\ 0)

  defp request(_request, 5) do
    {:error, :no_connection}
  end

  defp request(request, retry) do
    with worker <- Lifeguard.assign_worker(),
         {:ok, response} <- Connection.request(worker, request),
         :ok <- Lifeguard.return_worker(worker) do
      Response.decode(response)
    else
      {:error, :http_worker_down} ->
        request(request, retry + 1)
    end
  end
end
