defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  require Logger
  alias Remedy.Cache
  alias Remedy.Gateway.Producer
  alias Remedy.Gateway.Session.State

  def digest(
        %State{
          payload_dispatch_event: :READY
        } = socket,
        %{
          session_id: session_id,
          application: app,
          user: user,
          v: v
        } = payload
      ) do
    Cache.init_app(app)
    Cache.init_bot(user)
    Logger.debug("#{inspect(payload, pretty: true)}")

    %State{socket | v: v, session_id: session_id}
  end

  def digest(%State{payload_dispatch_event: payload_dispatch_event} = socket, payload) do
    with :ok <- Producer.digest({payload_dispatch_event, payload, socket}) do
      socket
    end
  end
end
