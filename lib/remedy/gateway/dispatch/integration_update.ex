defmodule Remedy.Gateway.Dispatch.IntegrationUpdate do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, %{id: id} = payload, socket}) do
    with {:ok, integration} <- Cache.update_integration(id, payload) do
      {event, integration, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
