defmodule Remedy.Gun do
  require Logger

  @moduledoc """
  Helpers for Gun so that I can lose the erlang syntax.

  Everything takes a `%Websocket{}` and returns a `%Websocket{}`.
  """
  alias Remedy.Gateway.Websocket
  @gateway_qs "/?compress=zlib-stream&encoding=etf&v=9"
  @gun_opts %{protocols: [:http], retry: 1_000_000_000}
  @gun_port 443
  @gun_timeout_connect 10_000

  @doc """
  Combines `:gun.open` and `:gun.await_up`. Because we use them both together anytime we use them anyway.
  """
  def open_await(socket)

  def open_await(%Websocket{gateway: gateway} = socket) do
    case :gun.open(:binary.bin_to_list(gateway), @gun_port, @gun_opts) do
      {:ok, worker} ->
        %{socket | worker: worker} |> await_up()
    end
  end

  defp await_up(socket)

  defp await_up(%Websocket{gun_worker: gun_worker} = socket) do
    case :gun.await_up(gun_worker, @gun_timeout_connect) do
      {:ok, :http} -> socket
    end
  end

  @doc """
  Same as above. Upgrades the conn to websocket and holds the process until its good to go.
  """
  def upgrade_ws_await(socket)

  def upgrade_ws_await(%Websocket{gun_worker: gun_worker} = socket) do
    %{socket | stream: :gun.ws_upgrade(gun_worker, @gateway_qs)} |> await_ws()
  end

  defp await_ws(%{gun_worker: gun_worker, gun_data_stream: gun_data_stream} = state) do
    case :gun.await(gun_worker, gun_data_stream, @gun_timeout_connect) do
      {:upgrade, [<<"websocket">>], _headers} -> state
    end
  end

  @doc """
  Send the payload.
  """
  def send(payload, %Websocket{gun_worker: gun_worker, gun_data_stream: gun_data_stream} = socket) do
    case :gun.ws_send(gun_worker, gun_data_stream, {:binary, payload}) do
      :ok -> socket
    end
  end

  #####
  ### Non :gun but still helper with Gun
  #####
  def zlib_init(socket)

  def zlib_init(socket) do
    zlib_context = :zlib.open()

    case :zlib.inflateInit(zlib_context) do
      :ok -> %{socket | zlib_context: zlib_context}
    end
  end

  def close(%Websocket{gun_worker: gun_worker, gun_data_stream: gun_data_stream} = socket) do
    case :gun.ws_send(gun_worker, gun_data_stream, :close) do
      :ok -> socket
    end
  end

  def unpack_frame(%Websocket{zlib_context: zlib_context} = socket, frame) do
    payload = :zlib.inflate(zlib_context, frame) |> :erlang.iolist_to_binary() |> :erlang.binary_to_term()

    {payload, socket}
  end
end
