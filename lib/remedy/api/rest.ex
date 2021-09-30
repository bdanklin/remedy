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
  alias Remedy.API.{RestResponse, RestRequest}
  require Logger

  @doc false
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def init(_args) do
    {:ok, %__MODULE__{}, {:continue, :start_ratelimiter}}
  end

  @doc false
  def handle_continue(:start_ratelimiter, state) do
    {:noreply, state |> Gun.open_http2()}
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

  alias Remedy.API.{RestRequest, RestResponse, Ratelimiter}
  alias Remedy.Gun

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

  ## Error Sending Request
  defp process_response({:error, reason}, _request) do
    Logger.warn("ERROR #{reason}")

    {:error, reason}
  end

  ## Poorly formed request
  defp process_response(
         {:ok, %RestResponse{body: %{code: code, message: message}, status: 403}},
         %RestRequest{}
       ) do
    Logger.info("REQUEST REJECTED: #{message}")
    {:error, {code, message}}
  end

  ## A-OK
  defp process_response({:ok, %RestResponse{body: body} = _response}, %RestRequest{} = _request) do
    ## Inc Ratelimiter
    {:ok, body}
  end
end
