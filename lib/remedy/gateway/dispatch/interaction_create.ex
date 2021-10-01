defmodule Remedy.Gateway.Dispatch.Interaction do
  @moduledoc false

  alias Remedy.Schema.Interaction

  def handle({event, payload, socket}) do
    {event,
     payload
     |> Interaction.new(), socket}
  end
end
