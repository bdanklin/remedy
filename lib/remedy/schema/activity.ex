defmodule Remedy.Schema.Activity do
  @moduledoc """
  Discord Activity Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          party_id: String.t()
        }

  @primary_key false
  embedded_schema do
    field :type, :integer
    field :party_id, :string
  end
end
