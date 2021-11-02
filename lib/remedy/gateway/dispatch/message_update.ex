defmodule Remedy.Gateway.Dispatch.MessageUpdate do
  @moduledoc false
  alias Remedy.{Cache, Util}

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end
end
