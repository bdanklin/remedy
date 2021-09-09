defmodule Remedy.Gateway.Commands.Resume do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :token, :string
    field :session_id, :string
    field :sequence, :integer
  end

  def payload(socket, opts \\ [])

  def payload(%Websocket{session: session_id, sequence: sequence} = socket, _opts) do
    %{
      session_id: session_id,
      sequence: sequence,
      token: Application.get_env(:remedy, :token)
    }
    |> build_payload(socket)
  end
end
