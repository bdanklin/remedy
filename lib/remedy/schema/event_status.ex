defmodule Remedy.Schema.EventStatus do
  use Remedy.Type
  defstruct SCHEDULED: 1, ACTIVE: 2, COMPLETED: 3, CANCELED: 4
end
