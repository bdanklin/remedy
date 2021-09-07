defmodule Remedy.Voice.Supervisor do
  @moduledoc false

  use Supervisor

  alias Remedy.Voice.Session
  alias Remedy.Voice.Websocket
  use Remedy.Schema
  require Logger

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: VoiceSupervisor)
  end

  def init(_opts) do
    children = [
      Remedy.Voice
    ]

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end

  def create_session(%VoiceState{} = voice) do
    child = %{
      id: voice.guild_id,
      start: {Session, :start_link, [voice]}
    }

    Supervisor.start_child(VoiceSupervisor, child)
  end

  def end_session(guild_id) do
    VoiceSupervisor |> Supervisor.terminate_child(guild_id)
    VoiceSupervisor |> Supervisor.delete_child(guild_id)
  end
end
