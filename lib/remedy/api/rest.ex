defmodule Remedy.API.Rest do
  @moduledoc false
  @type conn() :: pid()
  @type reason :: term()
  @type message :: term()
  @type body :: term()
  @type code :: integer()
  @type t() :: %__MODULE__{
          conn: conn,
          port: 443,
          protocol: :http2
        }

  defstruct [
    :conn,
    port: 443,
    protocol: :http2
  ]

  use GenServer
  alias Remedy.Gun
  alias Remedy.API.{Ratelimiter, RestRequest, RestResponse}
  require Logger

  @doc false
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @doc false
  def init(state) do
    {:ok, state |> Gun.open_http2()}
  end

  @doc """
  Process a `%RestRequest{}`.

  Returns a `%RestResponse{}`
  """
  @spec request(%RestRequest{}) :: {:error, reason | {code, message}} | {:ok, body}
  def request(request) do
    GenServer.call(__MODULE__, {:queue, request}, :infinity)
  end

  ############
  ## Callbacks
  ############

  def handle_info({:gun_error, _conn, _stream, {what, why, reason}}, state) do
    what = what |> to_string() |> String.upcase()
    why = why |> to_string() |> String.upcase()

    Logger.warn("GUN ERROR: #{what}, #{why} #{reason}")
    {:noreply, state}
  end

  def handle_info({:gun_down, _conn, _proto, _reason, _killed_streams}, state) do
    {:noreply, state}
  end

  def handle_info({:gun_up, _conn, _proto}, state) do
    {:noreply, state}
  end

  def handle_call({:queue, %RestRequest{} = request}, _from, state) do
    {:reply,
     request
     |> Ratelimiter.run_check()
     |> Gun.request(state)
     |> process_response(request), state}
  end

  defp process_response(response, request)

  defp process_response({:error, reason}, _request) do
    Logger.warn("ERROR #{reason}")

    {:error, reason}
  end

  defp process_response(
         {:ok, %RestResponse{body: %{code: code, message: message}, status: status}},
         %RestRequest{}
       ) do
    Logger.info("REQUEST REJECTED: #{message}")
    {:error, {status, code, message}}
  end

  defp process_response({:ok, %RestResponse{body: body} = response}, %RestRequest{} = _request) do
    Logger.debug("#{inspect(response, pretty: true)}")
    {:ok, body}
  end
end
