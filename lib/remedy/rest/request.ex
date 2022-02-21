defmodule Remedy.Rest.Request do
  @moduledoc false

  ## Routes we can access with no auth header - ty Jup on Discord API
  # @no_auth_routes [
  #   "/invites/:code",
  #   "/entitlements/gift-codes/:code",
  #   "/guilds/:id/widget.json",
  #   "/applications/:id/rpc",
  #   "/webhook/:id/:token",
  #   "/gateway",
  #   "/applications/detectable"
  # ]
  @api_version "/api/v9"

  @type method :: :get | :post | :put | :patch | :delete
  @type route :: String.t()
  @type params :: map | nil
  @type reason :: String.t() | nil
  @type query :: map | nil
  @type body :: map | nil

  @type t :: %__MODULE__{
          method: method,
          route: String.t(),
          body: String.t(),
          headers: list(),
          __rate_limit__: any(),
          __discord_bucket__: any(),
          __raw__: %{
            method: method,
            route: route,
            params: params,
            query: query,
            reason: reason,
            body: body
          }
        }

  defstruct method: nil,
            route: nil,
            body: %{},
            headers: [
              {"Authorization", "Bot #{Remedy.token()}"},
              {"User-Agent", "DiscordBot (https://github.com/bdanklin/remedy, 0.6.9)"}
            ],
            __rate_limit__: %{},
            __discord_bucket__: nil,
            __raw__: nil

  require Logger
  @spec new(method, route, params, query, reason, body) :: t()
  def new(method, route, params, query, reason, body) do
    Logger.debug("Building Request")

    %__MODULE__{__raw__: %{method: method, route: route, params: params, query: query, reason: reason, body: body}}
    |> put_method()
    |> build_rate_limiter_info()
    |> build_route()
    |> build_query_params()
    |> build_audit_log_reason_header()
    |> build_body()
  end

  defp put_method(%{__raw__: %{method: method}} = request) do
    %__MODULE__{request | method: method}
  end

  # TODO: move to rate limiter?
  defp build_rate_limiter_info(%__MODULE__{__raw__: raw} = request) do
    major_param =
      cond do
        String.contains?(raw.route, "/:webhook_id/:webhook_token") ->
          "#{raw.params.webhook_id} <> #{raw.params.webhook_token}"

        true ->
          raw.route
          |> String.split("/")
          |> Enum.filter(&String.contains?(&1, ":"))
          |> Enum.reduce_while(nil, fn
            ":guild_id", nil -> {:halt, ":guild_id"}
            ":channel_id", nil -> {:halt, ":channel_id"}
            _param, _acc -> {:cont, nil}
          end)
      end
      |> Base.encode64()

    route =
      raw.route
      |> :zlib.zip()
      |> Base.encode64()

    %__MODULE__{request | __rate_limit__: {raw.method, major_param, route}}
  end

  defp build_route(%__MODULE__{__raw__: %{route: route, params: nil}} = request) do
    %__MODULE__{request | route: route}
  end

  defp build_route(%__MODULE__{__raw__: %{route: route, params: params}} = request) do
    params = for {k, v} <- params, into: [], do: {":" <> to_string(k), v}
    route = Enum.reduce(params, route, fn {k, v}, acc -> String.replace(acc, k, v) end)
    %__MODULE__{request | route: route}
  end

  defp build_query_params(%__MODULE__{__raw__: %{route: route, query: nil}} = request) do
    route = (@api_version <> route) |> URI.encode()
    %__MODULE__{request | route: route}
  end

  defp build_query_params(%__MODULE__{__raw__: %{route: route, query: query}} = request) do
    route = (@api_version <> route <> "?" <> URI.encode_query(query, :rfc3986)) |> URI.encode()
    %__MODULE__{request | route: route}
  end

  defp build_audit_log_reason_header(%__MODULE__{__raw__: %{reason: nil}} = request) do
    request
  end

  defp build_audit_log_reason_header(%__MODULE__{headers: headers, __raw__: %{reason: reason}} = request) do
    headers = headers ++ [{"X-Audit-Log-Reason", reason |> URI.encode()}]
    %__MODULE__{request | headers: headers}
  end

  defp clrf, do: "\r\n"
  defp boundary, do: "--" <> Base.encode64(:crypto.strong_rand_bytes(16))

  defp build_body(%__MODULE__{headers: headers, __raw__: %{body: body}} = request) do
    body
    |> map_embeds()
    |> map_attachments()
    |> case do
      {body, []} ->
        %__MODULE__{
          request
          | body: Jason.encode!(body),
            headers: [{"content-type", "application/json"}] ++ headers
        }

      {body, attachments} ->
        boundary = boundary()

        body = %{
          id: :json,
          data: Jason.encode!(body),
          mime: "application/json"
        }

        cr = clrf()

        %__MODULE__{
          request
          | body: encode_multipart(body, attachments, boundary, cr),
            headers: [{"content-type", "multipart/form-data; boundary=\"#{boundary}\""}] ++ headers
        }
    end
  end

  defp encode_multipart(body, attachments, boundary, cr) do
    ([body] ++ attachments)
    |> Enum.reduce([], fn
      x, acc -> encode_part(x, acc)
    end)
    |> Enum.intersperse(boundary)
    |> List.flatten()
    |> Enum.intersperse(cr)
    |> Enum.reverse()
    |> Enum.into("")
  end

  defp encode_part(%{id: :json, data: data}, acc) do
    part = [
      "content-disposition: form-data; name=\"payload_json\"",
      "content-type: application/json",
      "",
      data
    ]

    [acc | part]
  end

  defp encode_part(%{id: id, data: data, mime: mime, filename: filename, ext: ext}, acc) do
    part = [
      "content-disposition: form-data; name=\"files[#{id}]\"; filename=\"#{filename}.#{ext}\"",
      "content-type: #{mime}",
      "",
      data
    ]

    [acc | part]
  end

  defp encode_part(%{id: nil, data: data, mime: mime, filename: filename, ext: ext}, acc) do
    part = [
      "content-disposition: form-data; filename=\"#{filename}.#{ext}\"",
      "content-type: #{mime}",
      "",
      data
    ]

    [acc | part]
  end

  alias Remedy.Attachment

  defp map_embeds(%{embeds: embeds} = body) do
    {updated_embeds, attachments_from_embeds} = embeds_paths(embeds)
    {%{body | embeds: updated_embeds}, attachments_from_embeds}
  end

  defp map_embeds(body), do: {body, []}

  defp map_attachments({%{attachments: attachments} = body, attachments_from_embeds}) do
    {updated_attachments, attachments_from_attachments} = attachments_paths(attachments)
    {%{body | attachments: updated_attachments}, [attachments_from_attachments | attachments_from_embeds]}
  end

  defp map_attachments({body, attachments_from_embeds}),
    do: {body, attachments_from_embeds}

  defp embeds_paths(obj, acc \\ [])
  defp embeds_paths(obj, _acc) when is_tuple(obj), do: obj
  defp embeds_paths(objs, _acc) when is_list(objs), do: Enum.map(objs, &embeds_paths(&1))
  defp embeds_paths(nil, _acc), do: {nil, []}
  defp embeds_paths({_field, nil} = row, acc), do: {row, acc}

  defp embeds_paths(obj, acc) when is_map(obj) do
    {obj, acc} = Enum.map_reduce(obj, acc, &embeds_paths/2)
    {Enum.into(obj, %{}), acc}
  end

  defp embeds_paths({field, %Attachment{} = attachment}, acc),
    do: {{field, embed_attachment_url(attachment)}, [attachment | acc]}

  defp embeds_paths(row, acc), do: {row, acc}

  defp embed_attachment_url(%Attachment{filename: filename, ext: ext}) do
    "attachment://#{filename}#.#{ext}"
  end

  defp attachments_paths(obj, acc \\ {[], 0})
  defp attachments_paths(obj, _acc) when is_tuple(obj), do: obj
  defp attachments_paths(objs, _acc) when is_list(objs), do: Enum.map(objs, &attachments_paths(&1))
  defp attachments_paths({_field, nil} = row, acc), do: {row, acc}

  defp attachments_paths(%{} = obj, acc) do
    {obj, acc} = Enum.map_reduce(obj, acc, &attachments_paths/2)
    {Enum.into(obj, %{}), acc}
  end

  defp attachments_paths({field, %Attachment{} = attachment}, {acc, id}) when is_atom(field) do
    {{field, json_attachment(attachment, id)}, {[multipart_attachment(attachment, id) | acc], id + 1}}
  end

  defp attachments_paths(row, acc), do: {row, acc}

  defp json_attachment(%Attachment{description: description, filename: filename, ext: ext}, id) do
    %{id: id, description: description, filename: "#{filename}#.#{ext}"}
  end

  defp multipart_attachment(value, id) do
    %Attachment{value | id: id}
  end
end
