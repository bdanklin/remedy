defmodule Remedy.Gateway.Dispatch.ThreadUpdate do
  @moduledoc false

  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end
end
