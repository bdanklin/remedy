defmodule Remedy.Schema.MessageActivityType do
  use Remedy.Type
  defstruct JOIN: 1, SPECTATE: 2, LISTEN: 3, JOIN_REQUEST: 5
end
