defmodule Remedy.Gateway.Dispatch.IntegrationDelete do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, %{id: id} = _payload, socket}) do
    with {:ok, integration} <- Cache.delete_integration(id) do
      {event, integration, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
