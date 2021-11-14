defmodule Remedy.Gun do
  @moduledoc false
  require Logger
  alias Remedy.Gateway.WSState

  alias Remedy.API.{Rest, RestRequest, RestResponse}

  @gateway_qs "/?compress=zlib-stream&encoding=etf&v=9"

  @doc """
  Used for Restful operations over HTTP2
  """
  @spec open_http2(Remedy.API.Rest.t()) :: Remedy.API.Rest.t()
  def open_http2(%Rest{} = rest_state) do
    case :gun.open(:binary.bin_to_list("discord.com"), 443, %{
           protocols: [:http2],
           transport: :tls,
           http2_opts: %{
             keepalive: 5000
           },
           retry: 1_000_000_000
         }) do
      {:ok, conn} ->
        %Rest{rest_state | conn: conn} |> await_http2_up()
    end
  end

  defp await_http2_up(%Rest{conn: conn} = socket) do
    Logger.debug(inspect(socket))

    case :gun.await_up(conn, 10_000) do
      {:ok, :http2} -> socket
    end
  end

  @type status :: integer()
  @type headers :: keyword()
  @type body :: term
  @type reason :: term

  @spec request(Remedy.API.RestRequest.t(), Remedy.API.Rest.t()) ::
          {:error, binary} | {:ok, Remedy.API.RestResponse.t()}

  def request(%RestRequest{method: :get} = request, state),
    do: request |> log() |> get(state) |> await() |> prepare_response()

  def request(%RestRequest{method: :put} = request, state),
    do: request |> log() |> put(state) |> await() |> prepare_response()

  def request(%RestRequest{method: :post} = request, state),
    do: request |> log() |> post(state) |> await() |> prepare_response()

  def request(%RestRequest{method: :patch} = request, state),
    do: request |> log() |> patch(state) |> await() |> prepare_response()

  def request(%RestRequest{method: :delete} = request, state),
    do: request |> log() |> delete(state) |> await() |> prepare_response()

  defp log(request) do
    Logger.warn("#{inspect(request)}")
    request
  end

  defp get(%RestRequest{route: route, headers: headers}, %Rest{conn: conn}) do
    {:gun.get(conn, route, headers), conn}
  end

  defp put(%RestRequest{route: route, headers: headers, body: body}, %Rest{conn: conn}) do
    {:gun.put(conn, route, headers, body), conn}
  end

  defp post(%RestRequest{route: route, headers: headers, body: body}, %Rest{conn: conn}) do
    {:gun.post(conn, route, headers, body), conn}
  end

  defp patch(%RestRequest{route: route, headers: headers, body: body}, %Rest{conn: conn}) do
    {:gun.patch(conn, route, headers, body), conn}
  end

  defp delete(%RestRequest{route: route, headers: headers}, %Rest{conn: conn}) do
    {:gun.delete(conn, route, headers), conn}
  end

  defp await({stream, conn}) do
    case :gun.await(conn, stream) do
      {:response, :fin, status, headers} ->
        %RestResponse{status: status, headers: headers, body: ""}

      {:response, :nofin, status, headers} ->
        {:ok, body} = :gun.await_body(conn, stream)
        %RestResponse{status: status, headers: parse_headers(headers), body: parse_body(body)}

      {:error, reason} ->
        {:error, to_string(reason)}
    end
  end

  defp parse_headers(headers), do: Enum.into(headers, %{})
  defp parse_body(%{} = body), do: body |> Morphix.atomorphiform!()
  defp parse_body([_ | _] = body), do: for(b <- body, into: [], do: Morphix.atomorphiform!(b))
  defp parse_body(body), do: Jason.decode!(body) |> parse_body()

  defp prepare_response({:error, reason}), do: {:error, reason}
  defp prepare_response(%RestResponse{} = response), do: {:ok, response}

  def open_websocket(%WSState{gateway: gateway} = socket) do
    case :gun.open(:binary.bin_to_list(gateway), 443, %{
           protocols: [:http],
           retry: 1_000_000_000
         }) do
      {:ok, conn} ->
        {:ok, conn}

        %{socket | conn: conn}
        |> await_websocket_up()
    end
  end

  defp await_websocket_up(%WSState{conn: conn} = socket) do
    case :gun.await_up(conn, 10_000) do
      {:ok, :http} ->
        socket
        |> upgrade_ws_await()
    end
  end

  defp upgrade_ws_await(%WSState{conn: conn} = socket) do
    %{socket | gun_data_stream: :gun.ws_upgrade(conn, @gateway_qs)} |> await_ws()
  end

  defp await_ws(%{conn: conn, gun_data_stream: gun_data_stream} = state) do
    case :gun.await(conn, gun_data_stream, 10_000) do
      {:upgrade, ["websocket"], _headers} -> state
    end
  end

  def websocket_send(payload, %WSState{conn: conn, gun_data_stream: gun_data_stream} = socket) do
    case :gun.ws_send(conn, gun_data_stream, {:binary, payload}) do
      :ok -> socket
    end
  end

  def zlib_init(socket) do
    zlib_context = :zlib.open()

    case :zlib.inflateInit(zlib_context) do
      :ok -> %{socket | zlib_context: zlib_context}
    end
  end

  def close(%WSState{conn: conn, gun_data_stream: gun_data_stream} = socket) do
    case :gun.ws_send(conn, gun_data_stream, :close) do
      :ok -> socket
    end
  end

  def unpack_frame(%WSState{zlib_context: zlib_context} = socket, frame) do
    payload =
      :zlib.inflate(zlib_context, frame)
      |> :erlang.iolist_to_binary()
      |> :erlang.binary_to_term()

    {payload, socket}
  end
end
