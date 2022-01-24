defmodule Remedy.Schema.IntegrationAccount do
  @moduledoc """
  Integration Account Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: :string
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :name, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :name])
  end
end
