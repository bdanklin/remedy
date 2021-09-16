defmodule Remedy.Schema.ClientStatus do
  @moduledoc """
  Discord Client Status Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          desktop: String.t(),
          mobile: String.t(),
          web: String.t()
        }

  embedded_schema do
    field :desktop, :string
    field :mobile, :string
    field :web, :string
  end
end
