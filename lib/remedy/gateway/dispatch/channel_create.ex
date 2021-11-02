defmodule Remedy.Gateway.Dispatch.ChannelCreate do
  @moduledoc """
  Channel Create Event.

  ## Payload

  - `%Remedy.Schema.Channel{}`

  [Read More](https://discord.com/developers/docs/topics/gateway#channel-create)

  """
  require Logger
  alias Remedy.{Cache, Util}
  alias Remedy.Gateway.WSState

  @type socket :: WSState.t()
  @spec handle({any, map, socket}) :: :noop | {any, Remedy.Schema.Channel.t(), any}
  def handle({event, payload, socket}) do
    case Cache.create_channel(payload) do
      {:ok, channel} ->
        {event, channel, socket}

      {:error, %Ecto.Changeset{}} ->
        Util.log_malformed(event)
        :noop
    end
  end
end
