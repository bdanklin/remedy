defmodule Remedy.Rest.Request do
  @moduledoc false

  @type opts :: keyword()

  @type t :: %__MODULE__{
          method: :get | :post | :put | :patch | :delete,
          route: String.t(),
          headers: keyword() | map(),
          body: any,
          params: keyword(),
          reason: String.t() | nil
        }

  defstruct method: nil,
            route: nil,
            body: %{},
            params: nil,
            reason: nil,
            headers: [
              {"Authorization", "Bot #{Remedy.token()}"},
              {"User-Agent", "DiscordBot (https://github.com/bdanklin/remedy, 0.6.9)"}
            ]

  @spec new(any, any, any, any, any) :: Request.t()
  def new(method, route, params, reason, body) do
    %__MODULE__{
      method: method,
      route: route,
      params: params,
      reason: reason,
      body: body
    }
    |> add_query_params()
    |> add_audit_log_reason()
    |> add_body()
  end

  defp add_query_params(%__MODULE__{route: route, params: nil} = request) do
    route = ("/api/v9" <> route) |> URI.encode()
    %__MODULE__{request | route: route}
  end

  defp add_query_params(%__MODULE__{route: route, params: params} = request) do
    route = ("/api/v9" <> route <> "?" <> URI.encode_query(params, :rfc3986)) |> URI.encode()

    %__MODULE__{request | route: route}
  end

  defp add_audit_log_reason(%__MODULE__{reason: nil} = request) do
    request
  end

  defp add_audit_log_reason(%__MODULE__{headers: headers, reason: reason} = request) do
    headers = headers ++ [{"X-Audit-Log-Reason", reason |> URI.encode()}]

    %__MODULE__{request | headers: headers, reason: nil}
  end

  defp add_body(%__MODULE__{headers: headers, body: %{file: file} = body} = request) do
    body = [{:file, file, {"form-data", [{"filename", body[:content]}]}, [{"tts", body[:tts]}]}]

    %__MODULE__{request | body: body, headers: [{"content-type", "multipart/form-data"}] ++ headers}
  end

  defp add_body(%__MODULE__{headers: headers, body: body} = request) do
    body = Jason.encode!(body)
    headers = [{"content-type", "application/json"}] ++ headers

    %__MODULE__{request | body: body, headers: headers}
  end
end
