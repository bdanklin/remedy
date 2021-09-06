defmodule Remedy.Schema.Integration do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "integrations" do
    field :name, :string
    field :type, :string
    field :enabled, :boolean
    belongs_to :app, App
  end
end
