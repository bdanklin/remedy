defmodule Remedy.Rest.Connection.State do
  @moduledoc false

  @port 443
  @url 'discord.com'

  require Logger

  @type t :: %__MODULE__{
          conn: reference(),
          worker: integer(),
          token: String.t(),
          status: :up | :down
        }

  defstruct conn: nil,
            worker: nil,
            token: nil,
            status: nil

  def new(args) do
    %__MODULE__{worker: args.worker, token: args.token}
  end

  def handle_connect(%__MODULE__{worker: number} = state) do
    Logger.info("Starting HTTP Connection #{number}")

    state
    |> connect()
  end

  defp connect(%__MODULE__{worker: worker} = state) do
    opts = %{
      protocols: [:http2],
      transport: :tls,
      http2_opts: %{keepalive: 5000},
      retry: 1_000_000_000,
      tls_opts: [
        verify: :verify_peer,
        cacerts: :certifi.cacerts(),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    }

    with :ok <- Logger.info("HTTP Worker #{worker} Connecting..."),
         {:ok, conn} <- :gun.open(@url, @port, opts),
         :ok <- Logger.info("HTTP Worker #{worker} Connected..."),
         {:ok, :http2} <- :gun.await_up(conn, 10_000),
         :ok <- Logger.info("HTTP Worker #{worker} Ready") do
      %__MODULE__{state | conn: conn, status: :up}
    end
  end

  alias Remedy.Rest.Request
  alias Remedy.Rest.Response

  def handle_request(%__MODULE__{status: :down, worker: worker}, request) do
    Logger.warn("HTTP Worker #{worker} is down, cannot handle request")

    {:error, :http_worker_down}
  end

  def handle_request(
        %__MODULE__{
          conn: conn,
          token: token
        },
        %Request{
          method: method,
          route: route,
          headers: headers,
          body: body
        } = request
      ) do
    headers = [{"Authorization", "Bot #{token}"} | headers]

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

  def handle_error(%__MODULE__{worker: worker} = state, {what, why, reason}) do
    Logger.warn(" HTTP/2 CONNECTION #{worker} ERROR: #{what}, #{why} #{reason}. COMMITTING SEPPUKU (◑_◑)")

    %__MODULE__{state | status: :down}
    |> connect()
  end

  def handle_up(%__MODULE__{worker: worker} = state) do
    Logger.info("HTTP/2 CONNECTION #{worker}: READY")
    %__MODULE__{state | status: :down}
  end

  def handle_down(%__MODULE__{worker: worker} = state) do
    Logger.warn("HTTP/2 CONNECTION #{worker}: DOWN")
    %__MODULE__{state | status: :down}
  end
end
