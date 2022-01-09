defmodule Remedy.Gateway.Gun do
  @moduledoc false
  require Logger
  alias Remedy.Gateway.WSState

  ## Types
  ######################
  @type status :: integer()
  @type headers :: keyword()
  @type body :: term
  @type reason :: term

  ## Gateway Opts
  ######################
  @gateway_opts '/?compress=zlib-stream&encoding=etf&v=9'
  @websocket_url 'gateway.discord.gg'
  @websocket_port 443
  @websocket_opts %{protocols: [:http], retry: 3}

  ##  Maintain a Websocket Connection with the server
  ##
  ##  Initiate HTTP Connection
  ##  Wait For Connection
  ##  Initiate Websocket Upgrade
  ##  Wait For Upgrade
  ##  Initiate a Zlib Context To Handle ETF Decompression
  ##
  @spec open_websocket(WSState.t()) :: WSState.t() | {:error, reason}
  def open_websocket(%WSState{gateway: _} = socket) do
    with {:ok, conn} <- :gun.open(@websocket_url, @websocket_port, @websocket_opts),
         {:ok, :http} <- :gun.await_up(conn, 10_000),
         data_stream <- :gun.ws_upgrade(conn, @gateway_opts),
         {:upgrade, ["websocket"], _} <- :gun.await(conn, data_stream, 10_000),
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
