defmodule Remedy.Gun do
  @moduledoc false
  require Logger
  alias Remedy.Gateway.WSState
  alias Remedy.API.{Rest, RestRequest, RestResponse}

  @type status :: integer()
  @type headers :: keyword()
  @type body :: term
  @type reason :: term

  @http2_url 'discord.com'
  @http2_port 443
  @http2_opts %{
    protocols: [:http2],
    transport: :tls,
    http2_opts: %{keepalive: 5000},
    retry: 1_000_000_000
  }

  ##  Maintain a HTTP2 Connection with the server
  ##
  @spec open_http2(Remedy.API.Rest.t()) :: Remedy.API.Rest.t()
  def open_http2(%Rest{} = rest_state) do
    with {:ok, conn} <- :gun.open(@http2_url, @http2_port, @http2_opts),
         {:ok, :http2} <- :gun.await_up(conn, 10_000) do
      Logger.debug(inspect(rest_state))

      %Rest{rest_state | conn: conn}
    end
  end

  ## Send a request over HTTP.
  ## The request should be prepared using the RestRequest module.
  ##
  @spec request_http2(RestRequest.t(), Rest.t()) :: {:error, binary} | {:ok, RestResponse.t()}
  def request_http2(
        %RestRequest{method: method, route: route, headers: headers, body: body} = request,
        %Rest{conn: conn}
      ) do
    Logger.warn("#{inspect(request)}")

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
      {:ok, %RestResponse{status: status, headers: headers, body: Jason.decode!(body, keys: :strings)}}
    else
      {:response, :fin, status, headers} ->
        {:ok, %RestResponse{status: status, headers: headers, body: ""}}

      {:error, reason} ->
        {:error, to_string(reason)}
    end
  end

  @gateway_opts '/?compress=zlib-stream&encoding=etf&v=9'
  @websocket_url 'gateway.discord.gg'
  @websocket_port 443
  @websocket_opts %{
    protocols: [:http],
    retry: 3
  }

  ##  Maintain a Websocket Connection with the server
  ##
  ##  Initiate HTTP Connection
  ##  Wait For Connection
  ##  Initiate Websocket Upgrade
  ##  Wait For Upgrade
  ##  Initiate a Zlib Context To Handle ETF Decompression
  ##
  @spec open_websocket(WSState.t()) :: WSState.t() | {:error, reason}
  def open_websocket(%WSState{gateway: _gateway} = socket) do
    with {:ok, conn} <- :gun.open(@websocket_url, @websocket_port, @websocket_opts),
         {:ok, :http} <- :gun.await_up(conn, 10_000),
         data_stream <- :gun.ws_upgrade(conn, @gateway_opts),
         {:upgrade, ["websocket"], _headers} <- :gun.await(conn, data_stream, 10_000),
         zlib_context <- :zlib.open(),
         :ok <- :zlib.inflateInit(zlib_context) do
      %{socket | conn: conn, data_stream: data_stream, zlib_context: zlib_context}
    else
      error -> error
    end
  end

  def websocket_send(payload, %WSState{conn: conn, data_stream: data_stream} = socket) do
    case :gun.ws_send(conn, data_stream, {:binary, payload}) do
      :ok -> socket
    end
  end

  def close(%WSState{conn: conn, data_stream: data_stream} = socket) do
    with :ok <- :gun.ws_send(conn, data_stream, :close) do
      socket
    end
  end
end
