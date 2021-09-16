defmodule Remedy.Schema.Integration do
  @moduledoc """
  Integration Object
  """
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          enabled: boolean(),
          app: App.t()
        }

  embedded_schema do
    field :name, :string
    field :type, :string
    field :enabled, :boolean
    belongs_to :app, App
  end
end
