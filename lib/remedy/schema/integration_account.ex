defmodule Remedy.Schema.IntegrationAccount do
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: :string
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :name, :string
  end
end
