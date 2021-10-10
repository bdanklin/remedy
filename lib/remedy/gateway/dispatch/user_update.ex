defmodule Remedy.Gateway.Dispatch.UserUpdate do
  @moduledoc false

  alias Remedy.Schema.User

  def handle({event, payload, socket}) do
    {event, payload, socket}
  end
end
