defmodule Remedy.Rest.Connection.State do
  @moduledoc false
  require Logger
  ## conn:          HTTP CONNECTION PID
  ## url:           HTTP URL
  ## port:          HTTP PORT
  ## opts:          HTTP OPTIONS
  ## connection:    CONNECTION NUMBER

  ## alive_since:   Connection started                      System.os_time(1000)

  ## last_req:      Last Request Start Time                 System.os_time(1000)
  ## last_req_ms:   Last Request Time Taken                 System.os_time(1000)

  ## dt:            Running average of :req_ms      (:req_ms + :last_req_ms) / 2
  ## util:          Connection Utilization      :last_req - :req) / :last_req_ms

  defstruct conn: nil,
            url: 'discord.com',
            port: 443,
            connection: nil,
            alive_since: 0,
            last_req: nil,
            last_req_ms: nil,
            dt: nil,
            util: nil

  def new(number) do
    %__MODULE__{connection: number, alive_since: System.os_time(1000)}
  end

  def open_http2(%__MODULE__{connection: connection, url: url, port: port} = state) do
    with :ok <- Logger.info("HTTP Worker #{connection} Connecting..."),
         {:ok, conn} <- :gun.open(url, port, opts()),
         :ok <- Logger.info("HTTP Worker #{connection} Connected..."),
         {:ok, :http2} <- :gun.await_up(conn, 10_000),
         :ok <- Logger.info("HTTP Worker #{connection} Ready") do
      %__MODULE__{state | conn: conn}
    end
  end

  defp opts() do
    %{
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
  end

  def join_pool_party(%__MODULE__{connection: connection} = state) do
    with :ok <- Remedy.Rest.Lifeguard.return_to_pool(connection) do
      state
    end
  end

  def return_to_pool(%__MODULE__{connection: connection} = state) do
    with :ok <- Remedy.Rest.Lifeguard.return_to_pool(connection) do
      state
    end
  end

  def update_utilization(%__MODULE__{last_req: nil, last_req_ms: nil} = state, req) do
    req_ms = System.os_time(1000) - req
    %__MODULE__{state | last_req: req, last_req_ms: req_ms}
  end

  def update_utilization(%__MODULE__{last_req: last_req, last_req_ms: last_req_ms} = state, req) do
    req_ms = System.os_time(1000) - req
    dt = (last_req_ms + req_ms) / 2
    util = req_ms / (req - last_req)

    %__MODULE__{state | last_req: req, last_req_ms: req_ms, dt: dt, util: util}
  end
end
