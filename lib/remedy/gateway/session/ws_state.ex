defmodule Remedy.Gateway.Session.WSState do
  @moduledoc false

  @opaque t :: %{}

  defstruct conn: nil,
            mod: Gateway,
            data_stream: nil,
            zlib: nil,
            token: nil,
            session_id: nil,
            v: nil,
            ## Shard
            shard: nil,
            shards: nil,
            ## Heartbeat
            heartbeat: 0,
            heartbeat_timer: nil,
            heartbeat_ack: nil,
            heartbeat_interval: nil,
            heartbeat_last_ack: nil,
            heartbeat_last_send: nil,
            ## Payload
            payload_dispatch_event: nil,
            payload_op_code: nil,
            payload_sequence: nil

  def new(args) do
    %__MODULE__{
      token: args[:token],
      shard: args[:shard],
      shards: args[:shards]
    }
  end

  def open_websocket(%__MODULE__{} = socket) do
    with {:ok, conn} <- :gun.open(url(), port(), conn_opts()),
         {:ok, :http} <- :gun.await_up(conn, 10_000),
         data_stream <- :gun.ws_upgrade(conn, gateway_opts()),
         {:upgrade, ["websocket"], _} <- :gun.await(conn, data_stream, 10_000) do
      %__MODULE__{socket | conn: conn, data_stream: data_stream}
    end
  end

  def init_zlib(%__MODULE__{zlib: _} = socket) do
    with zlib <- :zlib.open(), :ok <- :zlib.inflateInit(zlib) do
      %__MODULE__{socket | zlib: zlib}
    end
  end

  def close_websocket(%__MODULE__{conn: conn, data_stream: data_stream} = socket) do
    with :ok <- :gun.ws_send(conn, data_stream, :close) do
      socket
    end
  end

  def put_heartbeat_interval(socket, heartbeat_interval) do
    %__MODULE__{socket | heartbeat_interval: heartbeat_interval}
  end

  ############################################################################
  ## Configuration

  @doc false
  def port do
    443
  end

  @doc false
  def url do
    "gateway.discord.gg"
    |> :erlang.binary_to_list()
  end

  @doc false
  def gateway_opts do
    %{
      compress: :"zlib-stream",
      encoding: :etf,
      v: 10
    }
    |> URI.encode_query(:rfc3986)
    |> then(&Kernel.<>("/?", &1))
    |> :erlang.binary_to_list()
  end

  @doc false
  def conn_opts do
    %{
      protocols: [:http],
      retry: 3,
      ws_opts: %{keepalive: 5000},
      tls_opts: [
        verify: :verify_peer,
        cacerts: :certifi.cacerts(),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    }
  end
end
