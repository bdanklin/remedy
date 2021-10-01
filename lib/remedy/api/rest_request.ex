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
end
