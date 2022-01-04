defmodule Remedy.Application do
  @moduledoc false

  use Application
  require Logger

  @doc false
  def start(_type, _args) do
    children = [
      Remedy.API.Ratelimiter,
      Remedy.API.Rest,
      Remedy.Repo,
      Remedy.GatewayATC,
      Remedy.Gateway,
      Remedy.DevConsumerSupervisor
    ]

    with :ok <- check_token(),
         :ok <- check_executables() do
      Supervisor.start_link(children, strategy: :one_for_one)
    end
  end

  defp check_token, do: check_token(Application.get_env(:remedy, :token))
  defp check_token(nil), do: raise("Please supply a token")
  defp check_token(<<_::192, 46, _::48, 46, _::216>>), do: :ok
  defp check_token(_invalid), do: raise("Invalid token")

  defp check_executables do
    ff = Application.get_env(:remedy, :ffmpeg)
    yt = Application.get_env(:remedy, :youtubedl)
    sl = Application.get_env(:remedy, :streamlink)

    cond do
      is_binary(ff) and is_nil(System.find_executable(ff)) ->
        Logger.error("""
        #{ff} was not found in your path. By default, Remedy requires ffmpeg to use voice.
        If you don't intend to use voice with ffmpeg, configure :remedy, :ffmpeg to nil to suppress.
        """)

      is_binary(yt) and is_nil(System.find_executable(yt)) ->
        Logger.error("""
        #{yt} was not found in your path. Remedy supports youtube-dl for voice.
        If you don't require youtube-dl support, configure :remedy, :youtubedl to nil to suppress.
        """)

      is_binary(sl) and is_nil(System.find_executable(sl)) ->
        Logger.error("""
        #{sl} was not found in your path. Remedy supports streamlink for voice.
        If you don't require streamlink support, configure :remedy, :streamlink to nil to suppress.
        """)

      true ->
        :ok
    end
  end
end
