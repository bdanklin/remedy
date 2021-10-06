defmodule Remedy.Gateway.Dispatch.WebhooksUpdate do
  @moduledoc false
  alias Remedy.Schema.WebhooksUpdate

  def handle({event, payload, socket}) do
    {event, payload |> WebhooksUpdate.new(), socket}
  end
end
