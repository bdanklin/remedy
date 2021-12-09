defmodule Remedy.API.RestRequest do
  @moduledoc false

  @type method :: :get | :post | :put | :patch | :delete
  @type route :: String.t()
  @type headers :: keyword() | map()
  @type body :: any
  @type params :: keyword()
  @type reason :: String.t() | nil

  @type t :: %__MODULE__{
          method: method,
          route: route,
          headers: headers,
          body: body,
          params: params,
          reason: reason
        }

  defstruct [
    :method,
    :route,
    body: %{},
    params: nil,
    reason: nil,
    headers: [
      {"Authorization", "Bot #{Application.get_env(:remedy, :token)}"},
      {"User-Agent", "DiscordBot (https://github.com/bdanklin/remedy, 0.6.8)"}
    ]
  ]

  @spec new(any, binary, any, any, any) :: RestRequest.t()
  def new(method, route, params, reason, body) do
    %__MODULE__{method: method, route: route, params: params, reason: reason, body: body}
    |> IO.inspect()
    |> add_query_params()
    |> add_audit_log_reason()
    |> add_body()
  end

  defp add_query_params(%__MODULE__{route: route, params: nil} = request) do
    route = "/api/v9" <> route

    %__MODULE__{request | route: route |> URI.encode()}
  end

  defp add_query_params(%__MODULE__{route: route, params: params} = request) do
    route = "/api/v9" <> route <> "?" <> URI.encode_query(params, :rfc3986)

    %__MODULE__{request | route: route |> URI.encode()}
  end

  defp add_audit_log_reason(%__MODULE__{reason: nil} = request) do
    request
  end

  defp add_audit_log_reason(%__MODULE__{headers: headers, reason: reason} = request) do
    headers = headers ++ [{"X-Audit-Log-Reason", reason |> URI.encode()}]

    %__MODULE__{request | headers: headers, reason: nil}
  end

  ## MULTIPART/FORM-DATA
  ## This is only used for file uploads.
  ##
  defp add_body(%__MODULE__{headers: headers, body: %{file: file} = body} = request) do
    body = [
      {:file, file, {"form-data", [{"filename", body[:content]}]}, [{"tts", body[:tts]}]}
    ]

    headers = [{"content-type", "multipart/form-data"}] ++ headers

    %__MODULE__{request | body: body, headers: headers}
  end

  ## JSON
  ## Used for everything else.
  ##
  defp add_body(%__MODULE__{headers: headers, body: body} = request) do
    body = Jason.encode!(body)
    headers = [{"content-type", "application/json"}] ++ headers

    %__MODULE__{request | body: body, headers: headers}
  end
end
