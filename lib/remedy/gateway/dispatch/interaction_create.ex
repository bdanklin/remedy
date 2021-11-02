defmodule Remedy.Gateway.Dispatch.InteractionCreate do
  @moduledoc false
  alias Remedy.Schema.Interaction

  def handle({event, payload, socket}) do
    with {:ok, integration} <- Cache.create_integration(payload) do
      {event, integration, socket}
    else
      {:error, _reason} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
