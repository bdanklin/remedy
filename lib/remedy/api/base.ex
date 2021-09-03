defmodule Remedy.Api.Base do
  @moduledoc false

  @version Remedy.Mixfile.project()[:version]

  use HTTPoison.Base

  alias Remedy.Constants

  def process_url(url) do
    URI.encode(Constants.base_url() <> url)
  end

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Poison.encode!(body)

  def process_request_headers(headers) do
    user_agent = [
      {"User-Agent", "DiscordBot (https://github.com/bdanklin/remedy, #{@version})"} | headers
    ]

    token = "Bot " <> Application.get_env(:remedy, :token)

    [{"Authorization", token} | user_agent]
  end

  def process_response_body(body) do
    body
  end
end
