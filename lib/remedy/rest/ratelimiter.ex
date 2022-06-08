defmodule Remedy.Rest.Ratelimiter do
  @moduledoc false
  use GenServer

  @doc false
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @doc false
  def init(_args) do
    {:ok, :initial_state}
  end

  # TODO: move to rate limiter?
  def build_rate_limiter_info(%{__raw__: raw} = request) do
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

    %{request | __rate_limit__: {raw.method, major_param, route}}
  end
end
