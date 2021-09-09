defmodule Remedy.Gateway.Payload do
  @moduledoc false
  use Remedy.Schema, :payload
  @primary_key false
  embedded_schema do
    field :op, :integer
    field :d, :map
    field :s, :string
    field :t, :string, default: nil
  end

  def build(data, command_as_string, %Websocket{sequence: sequence} = socket) do
    %{
      socket
      | payload:
          %{}
          |> Map.put(:d, data)
          |> Map.put(:s, sequence)
          |> Map.put(:op, op(command_as_string))
          |> new()
          |> :erlang.term_to_binary()
    }
  end
end
