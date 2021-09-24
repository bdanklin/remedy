defmodule Remedy.Api.Base do
  @moduledoc false
  import Remedy.Api.Endpoints
  @version 0.52

  def request(conn, method, route, body, raw_headers, params) do
    headers = process_request_headers(raw_headers)

    method =
      method
      |> Atom.to_string()
      |> String.upcase()

    query_string = URI.encode_query(params)

    full_route = "#{base_route()}#{route}?#{query_string}"

    stream = :gun.request(conn, method, full_route, headers, process_request_body(body))

    case :gun.await(conn, stream) do
      {:response, :fin, status, headers} ->
        {:ok, {status, headers, ""}}

      {:response, :nofin, status, headers} ->
        {:ok, body} = :gun.await_body(conn, stream)
        {:ok, {status, headers, body}}

      {:error, _reason} = result ->
        result
    end
  end

  def process_request_body(""), do: ""
  def process_request_body({:multipart, content}), do: content
  def process_request_body(body), do: Jason.encode!(body)

  def process_request_headers(headers) do
    user_agent = [
      {"user-agent", "DiscordBot (https://github.com/bdanklin/remedy, #{@version})"} | headers
    ]

    token = "Bot #{Application.get_env(:remedy, :token)}"

    [{"authorization", token} | user_agent]
  end

  def process_response_body(body) do
    body
  end

  defp create_multipart(file, json, boundary) do
    {:multipart, create_multipart_body(file, json, boundary)}
  end

  defp create_multipart(body, boundary) do
    {:multipart, create_multipart_body(body, boundary)}
  end

  defp create_multipart_body(file, json, boundary) do
    {body, name} = get_file_contents(file)

    file_mime = MIME.from_path(name)
    file_size = byte_size(body)
    json_mime = MIME.type("json")
    json_size = byte_size(json)
    crlf = "\r\n"

    ~s|--#{boundary}#{crlf}| <>
      ~s|content-length: #{file_size}#{crlf}| <>
      ~s|content-type: #{file_mime}#{crlf}| <>
      ~s|content-disposition: form-data; name="file"; filename="#{name}"#{crlf}#{crlf}| <>
      body <>
      ~s|#{crlf}--#{boundary}#{crlf}| <>
      ~s|content-length: #{json_size}#{crlf}| <>
      ~s|content-type: #{json_mime}#{crlf}| <>
      ~s|content-disposition: form-data; name="payload_json"#{crlf}#{crlf}| <>
      json <>
      ~s|#{crlf}--#{boundary}--#{crlf}|
  end

  defp create_multipart_body(%{content: content, tts: tts, file: file}, boundary) do
    file_mime = MIME.from_path(file)
    file_size = byte_size(content)
    tts_mime = MIME.type("")
    tts_size = byte_size(tts)
    crlf = "\r\n"

    ~s|--#{boundary}#{crlf}| <>
      ~s|content-length: #{file_size}#{crlf}| <>
      ~s|content-type: #{file_mime}#{crlf}| <>
      ~s|content-disposition: form-data; name="file"; filename="#{file}"#{crlf}#{crlf}| <>
      content <>
      ~s|#{crlf}--#{boundary}#{crlf}| <>
      ~s|content-length: #{tts_size}#{crlf}| <>
      ~s|content-type: #{tts_mime}#{crlf}| <>
      ~s|content-disposition: form-data; name="tts"#{crlf}#{crlf}| <>
      tts <>
      ~s|#{crlf}--#{boundary}--#{crlf}|
  end

  defp get_file_contents(path) when is_binary(path) do
    {File.read!(path), path}
  end

  defp get_file_contents(%{body: body, name: name}), do: {body, name}

  defp generate_boundary do
    String.duplicate("-", 20) <>
      "KraigieNostrumCat_" <>
      Base.encode16(:crypto.strong_rand_bytes(10))
  end
end
