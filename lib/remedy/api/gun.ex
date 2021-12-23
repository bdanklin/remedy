defmodule Remedy.API.Gun do
  @moduledoc false
  require Logger
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
end
