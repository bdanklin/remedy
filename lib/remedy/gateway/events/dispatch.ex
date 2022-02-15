defmodule Remedy.Gateway.Events.Dispatch do
  @moduledoc false
  require Logger
  alias Remedy.Cache
  alias Remedy.Gateway.Session.WSState

  def digest(
        %WSState{payload_dispatch_event: :READY} = socket,
        %{session_id: session_id, application: app, user: user, v: v} = payload
      ) do
    ## Skip the pipeline on these
    Cache.init_app(app)
    Cache.init_bot(user)

    %WSState{socket | v: v, session_id: session_id}
    |> broadcast_to_event_buffer(payload)
  end

  def digest(%WSState{} = socket, payload) do
    socket
    |> broadcast_to_event_buffer(payload)
  end

  alias Remedy.Dispatch.Buffer

  defp broadcast_to_event_buffer(%WSState{payload_dispatch_event: event} = socket, payload) do
    with :ok <- Buffer.ingest({event, payload, socket}) do
      socket
    end
  end
end
