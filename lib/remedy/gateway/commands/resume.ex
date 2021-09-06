defmodule Remedy.Gateway.Commands.Resume do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :token, :string
    field :session_id, :string
    field :seq, :integer
  end

  def payload(state, opts \\ [])

  def payload(%WSState{session: session_id, seq: seq}, _opts) do
    %{
      session_id: session_id,
      seq: seq,
      token: Application.get_env(:remedy, :token)
    }
    |> build_payload()
  end
end
