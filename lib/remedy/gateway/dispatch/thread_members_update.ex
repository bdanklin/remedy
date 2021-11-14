defmodule Remedy.Gateway.Dispatch.ThreadMembersUpdate do
  @moduledoc false
  alias Remedy.Cache

  def handle({event, payload, socket}) do
    case Cache.update_thread_members(payload) do
      {:ok, thread} -> {event, thread, socket}
      {:error, _reason} -> :noop
    end
  end
end
