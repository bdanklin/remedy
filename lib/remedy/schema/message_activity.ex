defmodule Remedy.Schema.MessageActivity do
  @moduledoc """
  Discord Message Activity Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: MessageActivityType.t(),
          party_id: String.t()
        }

  @primary_key false
  embedded_schema do
    field :type, MessageActivityType
    field :party_id, :string
  end
end
