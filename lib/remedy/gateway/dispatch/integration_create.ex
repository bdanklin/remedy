defmodule Remedy.Gateway.Dispatch.IntegrationCreate do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, payload, socket}) do
    case Cache.create_integration(payload) do
      {:ok, integration} ->
        {event, integration, socket}

      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
