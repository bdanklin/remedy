defmodule Remedy.Gateway.Dispatch.IntegrationCreate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    case Cache.update_integration(payload) do
      {:ok, integration} ->
        {event, integration, socket}

      {:error, _reason} ->
        :noop
    end
  end
end
