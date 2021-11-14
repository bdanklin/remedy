defmodule Remedy.Gateway.Dispatch.ChannelDelete do
  @moduledoc false
  alias Remedy.Cache

  @spec handle({any, %{:id => any, optional(any) => any}, any}) :: :noop | {any, Remedy.Schema.Channel.t(), any}
  def handle({event, %{id: id}, socket}) do
    case Cache.delete_channel(id) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end
end
