defmodule Remedy.Rest.Connection do
  @moduledoc false
  use GenServer
  require Logger

  alias Remedy.Rest.Request
  alias Remedy.Rest.Response
  alias Remedy.Rest.Connection.State

  @doc false
  def child_spec(number) do
    %{
      id: {__MODULE__, number},
      start: {__MODULE__, :start_link, number},
      restart: :transient,
      shutdown: 5000
    }
  end

  @doc false
  def start_link(number) do
    GenServer.start_link(__MODULE__, number, name: :"CONNECTION_#{number}")
  end

  @doc false
  def init(number) do
    Logger.info("Starting HTTP Connection #{number}")

    {:ok,
     State.new(number)
     |> State.open_http2()
     |> State.join_pool_party()}
  end

  def handle_call({:request, request}, _from, state) do
    request_time = System.os_time(1000)
    {:reply, request(request, state), state, {:continue, {:return_to_pool, request_time}}}
  end

  def handle_continue({:return_to_pool, req}, state) do
    {:noreply,
     state
     |> State.update_utilization(req)
     |> State.return_to_pool()}
  end

  defp request(
         %Request{method: method, route: route, headers: headers, body: body} = request,
         %State{conn: conn}
       ) do
    stream =
      case method do
        :get -> :gun.get(conn, route, headers)
        :put -> :gun.put(conn, route, headers, body)
        :post -> :gun.post(conn, route, headers, body)
        :patch -> :gun.patch(conn, route, headers, body)
        :delete -> :gun.delete(conn, route, headers)
      end

    with {:response, :nofin, status, headers} <- :gun.await(conn, stream),
         {:ok, body} <- :gun.await_body(conn, stream) do
      {:ok,
       %Response{
         status: status,
         headers: headers,
         body: Jason.decode!(body, keys: :strings),
         request: request
       }}
    else
      {:response, :fin, status, headers} ->
        {:ok, %Response{status: status, headers: headers, body: "", request: request}}

      {:error, reason} ->
        {:error, to_string(reason)}
    end
  end

  def handle_info(
        {:gun_error, _conn, _stream, {what, why, reason}},
        %State{connection: connection} = state
      ) do
    Logger.warn(
      " HTTP/2 CONNECTION #{connection} ERROR: #{what}, #{why} #{reason}. COMMITTING SEPPUKU (◑_◑)"
    )

    {:noreply, state}
  end

  def handle_info(
        {:gun_down, _conn, _proto, _reason, _killed_streams},
        %State{connection: connection} = state
      ) do
    Logger.warn("HTTP/2 CONNECTION #{connection}: DOWN. COMMITTING SEPPUKU (◑_◑)")
    {:noreply, state}
  end

  def handle_info({:gun_up, _conn, _proto}, %State{connection: connection} = state) do
    Logger.warn("HTTP/2 CONNECTION #{connection}: READY")
    {:noreply, state}
  end
end
