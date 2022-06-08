defmodule Remedy.Voice.Session.WSState do
  @moduledoc false

  defstruct conn: nil,
            mod: Voice,
            ## Establishing a connection
            url: 'gateway.discord.gg',
            port: 443,
            conn_opts: %{
              protocols: [:http],
              retry: 3,
              ws_opts: %{keepalive: 5000},
              tls_opts: []
            },
            gateway_opts: %{v: 9},
            data_stream: nil,
            ## Voice State
            mute: nil,
            deaf: nil,
            speaking: nil,
            ## Heartbeat
            heartbeat: 0,
            heartbeat_timer: nil,
            heartbeat_ack: nil,
            heartbeat_interval: nil,
            heartbeat_last_ack: nil,
            heartbeat_last_send: nil,
            ## Payload
            payload_op_code: nil,
            payload_sequence: nil,
            payload_dispatch_event: nil,
            ## Session
            secret_key: nil,
            session_id: nil,
            guild_id: nil,
            channel_id: nil,
            v: 0,
            token: nil,
            ssrc: nil,
            ip: nil,
            udp_socket: nil,
            rtp_sequence: nil,
            rtp_timestamp: nil,
            ffmpeg_proc: nil,
            raw_audio: nil,
            raw_stateful: nil,
            player_pid: nil,
            identified: nil

  def new(_args) do
    %__MODULE__{}
  end

  def open_websocket(%__MODULE__{url: url, port: port, conn_opts: conn_opts, gateway_opts: gateway_opts} = socket) do
    gateway_opts =
      gateway_opts
      |> URI.encode_query(:rfc3986)
      |> then(&Kernel.<>("/?", &1))
      |> :erlang.binary_to_list()

    conn_opts = %{
      conn_opts
      | tls_opts: [
          verify: :verify_peer,
          cacerts: :certifi.cacerts(),
          depth: 3,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
    }

    with {:ok, conn} <- :gun.open(url, port, conn_opts),
         {:ok, :http} <- :gun.await_up(conn, 10_000),
         data_stream <- :gun.ws_upgrade(conn, gateway_opts),
         {:upgrade, ["websocket"], _} <- :gun.await(conn, data_stream, 10_000) do
      %__MODULE__{socket | conn: conn, data_stream: data_stream}
    else
      error -> error
    end
  end

  def put_heartbeat_interval(socket, %{heartbeat_interval: heartbeat_interval}) do
    %__MODULE__{socket | heartbeat_interval: heartbeat_interval}
  end

  def close_websocket(%__MODULE__{conn: conn, data_stream: data_stream} = socket) do
    with :ok <- :gun.ws_send(conn, data_stream, :close) do
      socket
    end
  end

  import Remedy.CaseHelpers,
    only: [to_pascal: 1]

  import Remedy.CastHelpers,
    only: [deep_destructor: 1, deep_string_key: 1]

  def send(%__MODULE__{mod: mod, conn: conn, data_stream: data_stream} = socket, command, opts \\ []) do
    op_code_mod =
      [Remedy, mod, OPCode]
      |> Module.concat()

    handler =
      command
      |> op_code_mod.to_integer()
      |> op_code_mod.to_binary()
      |> to_pascal()
      |> String.to_atom()

    module =
      [Remedy, mod, Commands, handler]
      |> Module.concat()

    payload =
      socket
      |> module.send(opts)

    payload =
      %{
        "d" => payload,
        "op" => op_code_mod.to_integer(command)
      }
      |> deep_destructor()
      |> deep_string_key()
      |> :erlang.term_to_binary()

    with :ok <- :gun.ws_send(conn, data_stream, {:binary, payload}) do
      socket
    end
  end
end
