defmodule Remedy.API.RestResponse do
  @moduledoc false
  require Logger

  @type t :: %__MODULE__{
          status: integer(),
          headers: keyword(),
          body: term
        }

  defstruct [:status, :headers, :body]

  @spec decode({:error, any} | {:ok, Remedy.API.RestResponse.t()}) :: {:error, any} | {:ok, any}
  def decode({:error, _reason} = error), do: error

  def decode({:ok, %__MODULE__{body: %{"message" => message, "retry_after" => retry_after}, status: 429}}) do
    Logger.warn("SUB LIMIT: #{message}")

    {:error, {429, :sub_rate_limit, ceil(retry_after)}}
  end

  def decode({:ok, %__MODULE__{body: body, status: 204}}) do
    {:ok, body}
  end

  def decode({:ok, %__MODULE__{body: %{"code" => code, "message" => message}, status: status} = response}) do
    Logger.debug("#{inspect(response, pretty: true)}")
    Logger.info("REQUEST REJECTED: #{message}")

    {:error, {status, code, message}}
  end

  def decode({:ok, %__MODULE__{body: body} = response}) do
    Logger.debug("#{inspect(response, pretty: true)}")

    {:ok, body |> parse_body()}
  end

  defp parse_body(%{} = body), do: body |> Morphix.atomorphiform!(:safe)
  defp parse_body([_ | _] = body), do: for(b <- body, into: [], do: Morphix.atomorphiform!(b, :safe))
  defp parse_body("null"), do: %{}
  defp parse_body([]), do: []
  defp parse_body(body), do: Jason.decode!(body) |> parse_body()
end
