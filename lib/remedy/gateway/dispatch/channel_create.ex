defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  @moduledoc false
  alias Remedy.Cache
  alias Remedy.Schema.Channel
  alias Remedy.Cache.Repo

  def handle({event, payload, socket}) do
    {event,
     Channel.new(payload)
     |> Cache.create_channel()
     |> Repo.insert!(), socket}
  end
end
