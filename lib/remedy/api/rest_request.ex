defmodule Remedy.API.RestRequest do
  @moduledoc false

  @type method :: :get | :post | :put | :patch | :delete
  @type route :: String.t()
  @type headers :: keyword()
  @type body :: term()
  @type opts :: keyword()

  @type t :: %__MODULE__{
          method: method,
          route: route,
          headers: headers,
          body: body,
          opts: opts
        }

  defstruct [
    :method,
    :route,
    :body,
    opts: %{},
    headers: [
      {"Authorization", "Bot #{Application.get_env(:remedy, :token)}"},
      {"User-Agent", "DiscordBot (https://github.com/bdanklin/remedy, 0.6.0)"}
    ]
  ]

  def base_request({method, route}) do
    %__MODULE__{method: method, route: route}
  end

  def add_request_query_params(%__MODULE__{route: route} = request, nil) do
    %__MODULE__{request | route: "/api/v9" <> route}
  end

  def add_request_query_params(%__MODULE__{route: route} = request, params) do
    %__MODULE__{request | route: "/api/v9" <> route <> "?" <> URI.encode_query(params)}
  end

  def add_request_audit_log_headers(%__MODULE__{} = request, nil), do: request

  def add_request_audit_log_headers(%__MODULE__{} = request, reason) do
    %__MODULE__{request | headers: [{"X-Audit-Log-Reason", reason |> URI.encode()}]}
  end

  ## MULTIPART
  def add_request_body(%__MODULE__{headers: headers} = request, %{file: file} = body) do
    %__MODULE__{
      request
      | body: [
          {
            :file,
            file,
            {"form-data", [{"filename", body[:content]}]},
            [{"tts", body[:tts]}]
          }
        ],
        headers: [{"content-type", "multipart/form-data"}] ++ headers
    }
  end

  ## JSON
  def add_request_body(%__MODULE__{headers: headers} = request, body) do
    %__MODULE__{
      request
      | body: Jason.encode!(body),
        headers: [{"content-type", "application/json"}] ++ headers
    }
  end
end
