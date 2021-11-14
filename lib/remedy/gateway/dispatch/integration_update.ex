defmodule Remedy.Gateway.Dispatch.IntegrationUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    with {:ok, integration} <- Cache.update_integration(payload) do
      {event, integration, socket}
    else
      {:error, _reason} ->
        :noop
    end
  end
end
