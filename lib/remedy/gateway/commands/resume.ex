defmodule Remedy.Gateway.Commands.Resume do
  @moduledoc false
  #############################################################################
  ## 6
  ## Resume
  ## Send
  ## Resume a previous session that was disconnected.

  use Remedy.Schema

  embedded_schema do
    field :token, :string
    field :session_id, :string
    field :session_name, :integer
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:token, :session_id, :session_name])
  end

  def send(socket, _opts) do
    %{
      token: socket.token,
      session_id: socket.session_id,
      sequence: socket.sequence
    }
    |> changeset()
  end
end
