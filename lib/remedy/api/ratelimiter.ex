defmodule Remedy.API.Ratelimiter do
  @moduledoc false

  alias Remedy.API.{RestRequest, RestResponse}
  use GenServer
  require ExRated
  require Logger

  def run_check(request) do
    with {:ok, _delay} <- check_global(),
         {:ok, _delay} <- check_route(request) do
      inc_global()

      request
    end
  end

  @doc false

  def check_global do
    ExRated.inspect_bucket("global", 1000, 50) |> analyse_bucket("global")
  end

  @spec check_route(binary | Remedy.API.RestRequest.t()) :: {:ok, :infinity | non_neg_integer}
  def check_route(%RestRequest{route: route}), do: route |> route_to_bucket() |> check_route()

  def check_route(route) when is_binary(route) do
    GenServer.call(__MODULE__, {:check, route}) |> analyse_bucket(route)
  end

  @spec inc_route(Remedy.API.RestResponse.t(), Remedy.API.RestRequest.t()) ::
          {:ok, :infinity | non_neg_integer}
  def inc_route(
        %RestResponse{headers: headers},
        %RestRequest{route: route}
      ) do
    {bucket, reset_after, limit} = header_tuple = headers_to_bucket_tuple(headers)
    GenServer.cast(__MODULE__, {:insert, {route, header_tuple}})
    inc_route(bucket, reset_after, limit)

    check_route(route)
  end

  def inc_route(bucket, reset_after, limit) do
    ExRated.check_rate(bucket, reset_after, limit)
  end

  def inc_global do
    ExRated.check_rate("global", 1000, 50)
  end

  ##################
  ### Bucket States
  ##################

  ## Request Can Be Sent
  def analyse_bucket(nil, _route), do: {:ok, 0}
  def analyse_bucket({_, x, _, _, _}, _route) when x > 0, do: {:ok, 0}

  def analyse_bucket({_, x, reset_in, _, _}, route) when 10 > x and x > 0 do
    "APPROACHING RATELIMIT FOR #{route}. REMAINING: #{x}, RESETS IN: #{reset_in}ms"
    |> Logger.warn()

    {:ok, 0}
  end

  def analyse_bucket({_, _, _, nil, nil}, _route), do: {:ok, 0}

  def analyse_bucket({_, 0, reset_in, _inserted_at, _updated_at}, route) do
    "RATELIMIT FOR #{route}. HOLDING REQUEST FOR: #{reset_in}ms"
    |> Logger.warn()

    Process.sleep(reset_in)
    {:ok, reset_in}
  end

  ####################
  ### Helper Functions
  ####################

  @standard ~w(oauth2 applications @me channels audit-logs messages crosspost reactions bulk-delete invites permissions typing pins recipients threads thread-members active archived public private emojis guilds members nick roles bans prune regions integrations widget widget.json vanity-url widget.png welcome-screen voice-states templates stage-instances stickers sticker-packs users connections webhooks slack github commands callback @original gateway bot call ring typing embed sync prune)

  @doc false
  def route_to_bucket(route) do
    route
    |> String.split(["/", "?"])
    |> Enum.filter(&(&1 in @standard))
    |> Enum.join()
  end

  @bucket "X-RateLimit-Bucket"
  @limit "X-RateLimit-Limit"
  @reset_after "X-RateLimit-Reset-After"

  @doc false
  def headers_to_bucket_tuple(headers) do
    bucket = List.keyfind(headers, @bucket, 0)
    limit = List.keyfind(headers, @limit, 0)
    reset_after = List.keyfind(headers, @reset_after, 0) * 1000

    {bucket, reset_after, limit}
  end

  @doc false
  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]}
    }
  end

  @doc false
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  @doc false
  def init(_args) do
    {:ok, %{}}
  end

  @doc false
  def handle_call({:check, route}, _from, state) do
    response =
      case Map.get(state, route) do
        {bucket, timeout, max_requests} ->
          {bucket, timeout, max_requests}

        nil ->
          nil
      end

    {:reply, response, state}
  end

  def handle_cast({:cast, {route, {bucket, reset_after, limit}}}, state) do
    {:noreply, state |> Map.put(route, {bucket, reset_after, limit})}
  end

  def handle_info({:clean, {route}}, state) do
    Map.get(state, route) |> elem(0) |> ExRated.delete_bucket()

    {:noreply, state |> Map.delete(route)}
  end
end
