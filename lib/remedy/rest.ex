defmodule Remedy.Rest do
  @moduledoc false

  use Supervisor
  alias Remedy.Rest.{Request, Response, Lifeguard, Pool}

  def start_link(args) do
    IO.inspect(args)
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

  def request(method, route, params, reason, body) do
    request = Request.new(method, route, params, reason, body)

    with worker <- Lifeguard.assign_worker(),
         response <- GenServer.call(:"CONNECTION_#{worker}", {:request, request}) do
      Lifeguard.return_to_pool(worker)
      Response.decode(response)
    end
  end
end
