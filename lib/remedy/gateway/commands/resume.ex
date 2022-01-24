defmodule Remedy.Gateway.Commands.Resume do
  @moduledoc false
  defstruct [:token, :session_id, :sequence]

  def send(%{token: token, session_id: session_id, payload_sequence: sequence}, _opts) do
    %__MODULE__{
      token: token,
      session_id: session_id,
      sequence: sequence
    }
  end
end
