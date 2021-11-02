defmodule Remedy.Gateway.Dispatch.StageInstanceUpdate do
  @moduledoc false
  alias Remedy.Schema.StageInstance

  def handle({event, payload, socket}) do
    {event, StageInstance.form(payload), socket}
  end
end
