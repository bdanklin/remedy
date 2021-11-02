defmodule Remedy.Gateway.Dispatch.StageInstanceCreate do
  @moduledoc false
  alias Remedy.Schema.StageInstance

  def handle({event, payload, socket}) do
    {event, StageInstance.form(payload), socket}
  end
end
