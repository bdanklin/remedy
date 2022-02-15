defmodule Remedy.Rest do
  @moduledoc false

  use Supervisor
  alias Remedy.Rest.{Request, Response, Lifeguard, Pool}

  @spec start_link(any) :: {:ok, pid}
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    children = [
      {Pool, []},
      {Lifeguard, args}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def request(method, route, params, query, reason, body) do
    with %Request{} = request <- Request.new(method, route, params, query, reason, body),
         worker <- Lifeguard.assign_worker(),
         # TODO: make less shit
         {:ok, response} <- GenServer.call(:"CONNECTION_#{worker}", {:request, request}) do
      Lifeguard.return_to_pool(worker)
      Response.decode(response)
    end
  end
end
