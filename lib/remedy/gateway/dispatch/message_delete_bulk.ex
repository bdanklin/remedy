defmodule Remedy.Gateway.Dispatch.MessageDeleteBulk do
  @moduledoc false

  alias Remedy.Cache
  alias Remedy.Schema.MessageDeleteBulk

  def handle({event, %{ids: ids} = payload, socket}) do
    for message <- ids do
      Cache.delete_message(message)
    end

    {event, payload |> MessageDeleteBulk.new(), socket}
  end
end
