defmodule Remedy.Api.Base do
  @moduledoc false

  @version Remedy.MixProject.project()[:version]
  @base_url "https://discord.com/api/v9"
  use HTTPoison.Base

  def process_url(url), do: URI.encode(@base_url <> url)

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _} = body), do: body
  def process_request_body(body), do: Jason.encode!(body)

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
