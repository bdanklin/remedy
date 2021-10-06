defmodule Remedy.Gateway.Dispatch.SpeakingUpdate do
  @moduledoc false

  alias Remedy.Schema.SpeakingUpdate

  def handle({event, payload, socket}) do
    {event, SpeakingUpdate.new(payload), socket}
  end
end
