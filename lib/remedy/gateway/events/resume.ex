defmodule Remedy.Gateway.Events.Resume do
  @moduledoc false
  use Remedy.Gateway.Payload

  embedded_schema do
    field :token_id, :string, default: Application.get_env(:remedy, :token)
    field :session_id, :string
    field :sequence, :integer
  end

  def payload(%WSState{} = socket, _opts) do
    {%__MODULE__{session_id: socket.session_id, sequence: socket.payload_sequence}, socket}
  end
end
