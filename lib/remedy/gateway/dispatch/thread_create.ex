defmodule Remedy.Gateway.Dispatch.ThreadCreate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    case Cache.update_channel(payload) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end
end
