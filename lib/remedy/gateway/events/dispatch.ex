defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  require Logger
  alias Remedy.Cache
  alias Remedy.Buffer.Producer
  alias Remedy.Gateway.Session.WSState

  def digest(
        %WSState{
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

    %WSState{socket | v: v, session_id: session_id}
  end

  def digest(%WSState{payload_dispatch_event: payload_dispatch_event} = socket, payload) do
    with :ok <- Producer.ingest({payload_dispatch_event, payload, socket}) do
      socket
    end
  end
end
