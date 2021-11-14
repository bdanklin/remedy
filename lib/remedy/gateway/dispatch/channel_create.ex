defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  @moduledoc false
  require Logger
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    payload
    |> Cache.update_channel()
    |> case do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end
end
